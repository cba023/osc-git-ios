//
//  ShakingView.m
//  Git@OSC
//
//  Created by chenhaoxiang on 14-9-19.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ShakingView.h"
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioToolbox.h>
#import "PKRevealController.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "ProjectCell.h"
#import "ProjectDetailsView.h"
#import "ReceivingInfoView.h"
#import "AwardView.h"
#import "LoginViewController.h"
#import "TTTAttributedLabel.h"
#import "UMSocial.h"

#define accelerationThreshold  0.4

@interface ShakingView () <UIActionSheetDelegate, TTTAttributedLabelDelegate>

@property CMMotionManager *motionManager;
@property SystemSoundID shakeSoundID;
@property SystemSoundID matchSoundID;

@property TTTAttributedLabel *luckMessage;
@property UIView *layer;
@property UIImageView *imageUp;
@property UIImageView *imageDown;
@property UIImageView *sweetPotato;

@property NSOperationQueue *operationQueue;
@property NSString *privateToken;
@property GLProject *project;
@property ProjectCell *projectCell;
@property AwardView *awardView;
@property BOOL shaking;

@end

@implementation ShakingView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"摇一摇";
    [self.navigationController.navigationBar setTranslucent:NO];
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = UIColorFromRGB(0x111111);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showMenu)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收货信息"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushReceivingInfoView)];
    
    [self setLayout];
    
    _operationQueue = [NSOperationQueue new];
    _motionManager = [CMMotionManager new];
    _motionManager.accelerometerUpdateInterval = 0.1;
    
    NSString *shakeMusicPath = [[NSBundle mainBundle] pathForResource:@"shake_sound_male" ofType:@"mp3"];
	AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:shakeMusicPath]), &_shakeSoundID);
    NSString *matchMusicPath = [[NSBundle mainBundle] pathForResource:@"shake_match" ofType:@"mp3"];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:matchMusicPath]), &_matchSoundID);
    
    _privateToken = [Tools getPrivateToken];
}

- (void)showMenu
{
    [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
    
    [self startAccelerometer];
    
    [[GLGitlabApi sharedInstance] fetchLuckMessageSuccess:^(id responseObject) {
                                                                _luckMessage.text = responseObject;
                                                            }
                                                  failure:^(NSError *error) {}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_motionManager stopAccelerometerUpdates];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void)startAccelerometer
{
    //以push的方式更新并在block中接收加速度
    
    [self.motionManager startAccelerometerUpdatesToQueue:_operationQueue
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                             }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    if (_shaking) {return;}
    _shaking = YES;
    double accelerameter = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2));
    
    if (accelerameter > 1.8f) {
        [_motionManager stopAccelerometerUpdates];
        [_operationQueue cancelAllOperations];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self shakeAnimation];
            if ([Tools isNetworkExist]) {
                [self requestProject];
            } else {
                [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
            }
        });
    }
    
    _shaking = NO;
}

-(void)receiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [_motionManager stopAccelerometerUpdates];
    } else {
        [self startAccelerometer];
    }
}


#pragma mark - 跳转到收货信息界面

- (void)pushReceivingInfoView
{
    if ([Tools getPrivateToken].length) {
        ReceivingInfoView *infoView = [ReceivingInfoView new];
        [self.navigationController pushViewController:infoView animated:YES];
    } else {
        LoginViewController *loginView = [LoginViewController new];
        [self.navigationController pushViewController:loginView animated:NO];
    }
}


- (void)setLayout
{
    _luckMessage = [TTTAttributedLabel new];
    _luckMessage.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _luckMessage.delegate = self;
    _luckMessage.backgroundColor = [UIColor clearColor];
    _luckMessage.textColor = [Tools uniformColor];
    _luckMessage.font = [UIFont systemFontOfSize:12];
    _luckMessage.numberOfLines = 0;
    _luckMessage.lineBreakMode = NSLineBreakByWordWrapping;
    [self.view addSubview:_luckMessage];
    
    _layer = [UIView new];
    _layer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_layer];
    
    _sweetPotato = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shakehideimg_man"]];
    _sweetPotato.contentMode = UIViewContentModeScaleAspectFill;
    [_layer addSubview:_sweetPotato];
    
    _imageUp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_logo_up"]];
    _imageUp.contentMode = UIViewContentModeScaleAspectFill;
    [_layer addSubview:_imageUp];
    
    _imageDown = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shake_logo_down"]];
    _imageDown.contentMode = UIViewContentModeScaleAspectFill;
    [_layer addSubview:_imageDown];
    
    _projectCell = [ProjectCell new];
    UITapGestureRecognizer *tapPC = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProjectCell)];
    [_projectCell addGestureRecognizer:tapPC];
    [_projectCell setHidden:YES];
    [self.view addSubview:_projectCell];
    
    _awardView = [AwardView new];
    UITapGestureRecognizer *tapAW = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAwardView)];
    [_awardView addGestureRecognizer:tapAW];
    _awardView.backgroundColor = [Tools uniformColor];
    [Tools roundView:_awardView cornerRadius:8.0];
    [_awardView setHidden:YES];
    [self.view addSubview:_awardView];
    
    for (UIView *subview in [self.view subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    for (UIView *subview in [_layer subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_luckMessage, _layer, _sweetPotato, _imageUp, _imageDown, _projectCell, _awardView);
    
    
    // luckMessage
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_luckMessage]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-5-[_luckMessage]-5-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    
    // layer
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-80-[_layer(195)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=50-[_layer(168.75)]->=50-|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_layer
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    
    // sweetPotato
    
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-60-[_sweetPotato(75)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDict]];
    
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-50-[_sweetPotato(56.25)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:viewsDict]];
    
    
    // imageUp and imageDown
    
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=1-[_imageUp(95.25)][_imageDown(95.25)]|"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [_layer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_imageUp(168.75)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    
    // projectCell
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_projectCell(>=81)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_projectCell]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    // awardView
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_awardView]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_awardView]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
}

- (void)tapProjectCell
{
    ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectID:_project.projectId];
    [self.navigationController pushViewController:projectDetails animated:YES];
}

- (void)tapAwardView
{
    ReceivingInfoView *receivingView = [ReceivingInfoView new];
    [self.navigationController pushViewController:receivingView animated:YES];
}

-(void)motionMethod:(CMDeviceMotion *)deviceMotion
{
    if (_shaking) {return;}
    
    _shaking = YES;
    
    CMAcceleration userAcceleration = deviceMotion.userAcceleration;
    if (fabs(userAcceleration.x) > accelerationThreshold ||
        fabs(userAcceleration.y) > accelerationThreshold ||
        fabs(userAcceleration.z) > accelerationThreshold)
    {
        [self shakeAnimation];
        if ([Tools isNetworkExist]) {
            [self requestProject];
        } else {
            [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
            [self startAccelerometer];
        }
    }
    
    _shaking = NO;
}

- (void)shakeAnimation
{
    [_projectCell setHidden:YES];
    [_awardView setHidden:YES];
    
    AudioServicesPlaySystemSound(_shakeSoundID);
    
    //[self rotate:_layer];
    [self moveImage];
}

- (void)rotate:(UIView *)view
{
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"transform"];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //view.layer.anchorPoint = CGPointMake(1, 0);
    translation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(-M_PI_4, 0, 0, 100)];
    
    translation.duration = 0.2;
    translation.repeatCount = 2;
    translation.autoreverses = YES;
    
    [view.layer addAnimation:translation forKey:@"translation"];
}

- (void)moveImage
{
    CABasicAnimation *moveUp = [CABasicAnimation animationWithKeyPath:@"position"];
    moveUp.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    moveUp.toValue = [NSValue valueWithCGPoint:CGPointMake(_imageUp.center.x, _imageUp.center.y - 50)];
    moveUp.duration = 0.5;
    moveUp.repeatCount = 1;
    moveUp.autoreverses = YES;
    
    CABasicAnimation *moveDown = [CABasicAnimation animationWithKeyPath:@"position"];
    moveDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    moveDown.toValue = [NSValue valueWithCGPoint:CGPointMake(_imageDown.center.x, _imageDown.center.y + 50)];
    moveDown.duration = 0.5;
    moveDown.repeatCount = 1;
    moveDown.autoreverses = YES;
    
    [_imageUp.layer addAnimation:moveUp forKey:@"moveUp"];
    [_imageDown.layer addAnimation:moveDown forKey:@"moveDown"];
}



- (void)requestProject
{
    [[GLGitlabApi sharedInstance] fetchARandomProjectWithPrivateToken:_privateToken
                                                              success:[self successBlock]
                                                              failure:[self failureBlock]];
}

- (GLGitlabSuccessBlock)successBlock
{
    return 

    ^(id responseObject) {
        if (responseObject == nil) {
            [Tools toastNotification:@"红薯跟你开了一个玩笑，没有为你找到项目" inView:self.view];
            return;
        }
        
        AudioServicesPlaySystemSound(_matchSoundID);
        _project = responseObject;
        
        if (_project.message) {
            [_awardView setMessage:_project.message andImageURL:_project.imageURL];
            [_awardView setHidden:NO];
            
            NSString *alertMessage = @"获得：%@\n\n温馨提示：\n请完善您的收货信息，方便我们给您邮寄奖品";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"恭喜你，摇到奖品啦!!!"
                                                                message:[NSString stringWithFormat:alertMessage, _project.message]
                                                               delegate:self
                                                      cancelButtonTitle:@"我知道了"
                                                      otherButtonTitles:@"分享", nil];
            
            [alertView show];
        } else {
            [Tools setPortraitForUser:_project.owner view:_projectCell.portrait cornerRadius:5.0];
            _projectCell.projectNameField.text = [NSString stringWithFormat:@"%@ / %@", _project.owner.name, _project.name];
            _projectCell.projectDescriptionField.text = _project.projectDescription.length > 0? _project.projectDescription: @"暂无项目介绍";
            _projectCell.languageField.text = _project.language ?: @"Unknown";
            _projectCell.forksCount.text = [NSString stringWithFormat:@"%i", _project.forksCount];
            _projectCell.starsCount.text = [NSString stringWithFormat:@"%i", _project.starsCount];
            
            [_projectCell setHidden:NO];
            
            [self startAccelerometer];
        }
    };
}

- (GLGitlabFailureBlock)failureBlock
{
    return
    
    ^(NSError *error) {
        [Tools toastNotification:@"红薯跟你开了一个玩笑，没有为你找到项目" inView:self.view];
        
        [self startAccelerometer];
    };
}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"打开链接", nil), nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}



#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self showShareView];
    }
}

- (void)showShareView
{
    NSString *projectURL = @"https://git.oschina.net";
    
    // 微信相关设置
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = projectURL;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = projectURL;
    
    [UMSocialData defaultData].extConfig.title = @"摇到奖品啦！";
    
    // 手机QQ相关设置
    
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    
    [UMSocialData defaultData].extConfig.qqData.title = @"摇到奖品啦！";
    
    // 新浪微博相关设置
    
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:projectURL];
    
    // 显示分享的平台icon
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5423cd47fd98c58f04000c52"
                                      shareText:[NSString stringWithFormat:@"我在Git@OSC app上摇到了%@，你也来瞧瞧呗！%@", _project.message, projectURL]
                                     shareImage:[Tools getScreenshot:self.view]
                                shareToSnsNames:@[
                                                  UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToSina
                                                  ]
                                       delegate:nil];
}


@end
