//
//  ShakingViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/20/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ShakingViewController.h"
#import "LoginViewController.h"
#import "ProjectDetailsView.h"
#import "ProjectCell.h"
#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "Tools.h"
#import "AwardView.h"
#import "ReceivingInfoView.h"
#import "UMSocial.h"

#import <CoreMotion/CoreMotion.h>
#import <AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import <TTTAttributedLabel.h>

static const double accelerationThreshold = 2.0f;

@interface ShakingViewController () <UIActionSheetDelegate, TTTAttributedLabelDelegate>

@property (nonatomic, strong) GLProject * project;
@property (nonatomic, strong) TTTAttributedLabel * luckMessage;

@property (nonatomic, strong) UIImageView * layer;
@property (nonatomic, strong) ProjectCell * cell;

@property (nonatomic, strong) CMMotionManager * motionManager;
@property (nonatomic, strong) NSOperationQueue * operationQueue;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) AwardView *awardView;
@property (nonatomic, assign) BOOL isShaking;

@end

@implementation ShakingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"摇一摇";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"收货信息"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushReceivingInfoView)];
    [self setLayout];
    
    _operationQueue = [NSOperationQueue new];
    _motionManager = [CMMotionManager new];
    _motionManager.accelerometerUpdateInterval = 0.1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startAccelerometer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:)
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



#pragma mark - 视图布局

- (void)setLayout
{
    _luckMessage = [TTTAttributedLabel new];
    _luckMessage.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _luckMessage.delegate = self;
    _luckMessage.backgroundColor = UIColorFromRGB(0x111111);
    _luckMessage.textColor = [Tools uniformColor];
    _luckMessage.font = [UIFont systemFontOfSize:12];
    _luckMessage.numberOfLines = 0;
    _luckMessage.lineBreakMode = NSLineBreakByWordWrapping;
    [_luckMessage setPreferredMaxLayoutWidth:200];
    [self.view addSubview:_luckMessage];
    
    _layer = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shaking"]];
    _layer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_layer];
    
    _cell = [ProjectCell new];
    [_cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProjectCell)]];
    _cell.hidden = YES;
    [self.view addSubview:_cell];
    
    _awardView = [AwardView new];
    UITapGestureRecognizer *tapAW = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAwardView)];
    [_awardView addGestureRecognizer:tapAW];
    _awardView.backgroundColor = [Tools uniformColor];
    [Tools roundView:_awardView cornerRadius:8.0];
    [_awardView setHidden:YES];
    [self.view addSubview:_awardView];
    
    for (UIView *view in self.view.subviews) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    for (UIView *view in _layer.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_luckMessage, _layer, _cell, _awardView);
    
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
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                             toItem:_layer    attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:50]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                             toItem:_layer    attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_layer(195)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_layer(168.75)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    // projectCell
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_cell(>=81)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_cell]|"
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


#pragma mark - 监听动作

-(void)startAccelerometer
{
    //以push的方式更新并在block中接收加速度
    
    [_motionManager startAccelerometerUpdatesToQueue:_operationQueue
                                         withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                             [self outputAccelertionData:accelerometerData.acceleration];
                                         }];
}

-(void)outputAccelertionData:(CMAcceleration)acceleration
{
    double accelerameter = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2));
    
    if (accelerameter > accelerationThreshold) {
        [_motionManager stopAccelerometerUpdates];
        [_operationQueue cancelAllOperations];
        if (_isShaking) {return;}
        _isShaking = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self rotate:_layer];
        });
    }
}

-(void)receiveNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [_motionManager stopAccelerometerUpdates];
    } else {
        [self startAccelerometer];
    }
}

#pragma mark - 动画效果

- (void)rotate:(UIView *)view
{
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    rotate.fromValue = [NSNumber numberWithFloat:0];
    rotate.toValue = [NSNumber numberWithFloat:M_PI / 3.0];
    rotate.duration = 0.18;
    rotate.repeatCount = 2;
    rotate.autoreverses = YES;
    
    [CATransaction begin];
    [self setAnchorPoint:CGPointMake(-0.2, 0.9) forView:view];
    [CATransaction setCompletionBlock:^{
        [self getFetchProject];
    }];
    [view.layer addAnimation:rotate forKey:nil];
    [CATransaction commit];
}


// 参考 http://stackoverflow.com/questions/1968017/changing-my-calayers-anchorpoint-moves-the-view

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x,
                                   view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x,
                                   view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

#pragma mark - 获取数据
- (void)getFetchProject
{
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    [_hud hide:YES];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/random", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager GET:strUrl
      parameters:@{
                   @"private_token" : [Tools getPrivateToken],
                   @"luck"          : @(1)
                   }
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             
             if ([responseObject count]) {
                 _project = [[GLProject alloc] initWithJSON:responseObject];
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
                     [_cell contentForProjects:_project];
                     [_cell setHidden:NO];
                 }
             } else {
                 [_hud hide:NO];
                 _hud.mode = MBProgressHUDModeCustomView;
                 _hud.detailsLabelText = @"红薯跟你开了一个玩笑，没有为你找到项目";
                 [_hud hide:YES afterDelay:1.0];
             }
             
             [self startAccelerometer];
             _isShaking = NO;
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             [_hud hide:NO];
             _hud.mode = MBProgressHUDModeCustomView;
             _hud.detailsLabelText = @"红薯跟你开了一个玩笑，没有为你找到项目";
             [_hud hide:YES afterDelay:1.0];
             
             [self startAccelerometer];
             _isShaking = NO;
         }];
}

#pragma mark - 响应点击事件

- (void)tapProjectCell
{
    ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectID:_project.projectId projectNameSpace:_project.nameSpace];
    [self.navigationController pushViewController:projectDetails animated:YES];
    
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:_layer];
}

#pragma mark - 抽奖活动信息
- (void)fetchForLuckMessage
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager GET:[NSString stringWithFormat:@"%@%@/luck_msg", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS]
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             _luckMessage.text = [responseObject objectForKey:@"message"] ?: @"";
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             NSLog(@"%@", error);
         }];
}

#pragma mark - 活动
- (void)tapAwardView
{
    ReceivingInfoView *receivingView = [ReceivingInfoView new];
    [self.navigationController pushViewController:receivingView animated:YES];
    
    [self setAnchorPoint:CGPointMake(0.5, 0.5) forView:_layer];
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

#pragma mark - 分享
- (void)showShareView
{
    NSString *projectURL = [GITAPI_HTTPS_PREFIX componentsSeparatedByString:@"/api/v3/"][0];;
    
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
