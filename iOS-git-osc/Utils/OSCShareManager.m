//
//  OSCShareManager.m
//  iosapp
//
//  Created by wupei on 2017/6/7.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCShareManager.h"
#import "Tools.h"
#import "UMSocial.h"
#import <MBProgressHUD.h>

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SHAREBOARD_HEIGHT curShareBoard.bounds.size.height
#define SHAREBOARD_WIDTH curShareBoard.bounds.size.width

@interface OSCShareManager ()<OSCShareBoardDelegate>
{
	__weak OSCShareBoard* _curShareBoard;
}

@end

@implementation OSCShareManager

static OSCShareManager* _shareManager ;
+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [OSCShareManager new];
    });
    return _shareManager;
}


- (void)showShareBoardWithProjectM:(GLProject *)projectM
                            URLStr:(NSString *)urlStr
                             image:(UIImage *)snipImg {
    if (_curShareBoard ){
       _curShareBoard = nil;
    }
    
    OSCShareBoard *curShareBoard = [OSCShareBoard shareBoardWithProjectModel:projectM urlStr:urlStr image:snipImg];
    
    _curShareBoard = curShareBoard;
    curShareBoard.frame = [UIScreen mainScreen].bounds;
    curShareBoard.delegate = self;
    
    [[UIApplication sharedApplication].keyWindow addSubview:curShareBoard];
    
    //蒙板
    [curShareBoard.bgView setAlpha:0.0];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.bgView setAlpha:0.5];
    } completion:^(BOOL finished) {
        
    }];
    //弹出分享框
    [curShareBoard.contentView setFrame:CGRectMake(0, SCREEN_HEIGHT , SHAREBOARD_WIDTH, SHAREBOARD_HEIGHT )];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [curShareBoard.contentView setFrame:CGRectMake(0, SCREEN_HEIGHT - SHAREBOARD_HEIGHT, SHAREBOARD_WIDTH, SHAREBOARD_HEIGHT)];
    } completion:^(BOOL finished) {
        
    }];
    
    
}


- (void)hiddenShareBoard
{
    if (_curShareBoard.superview) {
        [_curShareBoard removeFromSuperview];
    }
}

#pragma mark --- OSCShareBoardDelegate
- (BOOL)customShareModeWithShareBoard:(OSCShareBoard* )shareBoard
                     boardIndexButton:(NSInteger)buttonTag
{
    if ([_delegate respondsToSelector:@selector(shareManagerCustomShareModeWithManager:shareBoardIndexButton:)]) {
        [_delegate shareManagerCustomShareModeWithManager:self shareBoardIndexButton:buttonTag];
        return YES;
    }
    return NO;
}

@end



#pragma mark --- OSCShareBoard
@interface OSCShareBoard ()

@property (nonatomic, assign) NSInteger aboutId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *authordName;
@property (nonatomic, copy) NSString *digest;
@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy) NSString *descString;

@property (nonatomic, strong) UIImage *logoImage;
@property (nonatomic, strong) NSString* resourceUrl;

@property (nonatomic, assign) BOOL isImage;

@end

@implementation OSCShareBoard{
    BOOL _touchTrack;
}

+ (instancetype)shareBoardWithProjectModel:(GLProject *)projectM urlStr:(NSString *)urlStr image:(UIImage *)snipImg{
    OSCShareBoard *curShareBoard = [[[UINib nibWithNibName:@"OSCShareBoard" bundle:nil] instantiateWithOwner:nil options:nil] lastObject];
    curShareBoard.isImage = NO;
    [curShareBoard settingProjectModel:projectM URLStr:urlStr image:snipImg];
    return curShareBoard;
}

- (void)settingProjectModel:(GLProject *)projectM  URLStr:(NSString* )urlStr image:(UIImage *)snipImg{
    
    self.logoImage = snipImg;
    
    self.title = [NSString stringWithFormat:@"%@",projectM.name];
    
    self.href = urlStr ?: [NSString stringWithFormat:@"%@",urlStr];
    

    self.descString = [NSString stringWithFormat:@"我在关注%@的项目%@，你也来瞧瞧呗！%@", projectM.owner.name, projectM.name, urlStr];
}


- (NSString *)stringReplayOcc:(NSString *)trimmedHTML
{
    NSString *string = [trimmedHTML stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    string = [string substringToIndex:(string.length < 100 ? string.length : 100)];
    string = [NSString stringWithFormat:@"%@", string];
    return string;
}

- (IBAction)cancleAction:(id)sender {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (IBAction)buttonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    UIViewController* curViewController = [self topViewControllerForViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
	
    UMSocialUrlResource* resource = nil;
    if (self.resourceUrl && self.resourceUrl.length > 0) {
        resource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:self.resourceUrl];
    }
    
    switch (button.tag) {
        case 1: //weibo
        {
            if (_isImage) {
                [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeImage url:self.href];
            }else{
        
               [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:self.href];
            }
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSina]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
                                                                }
                                                            }];
            
            break;
        }
        case 2: //Wechat Timeline
        {
            
            if (_isImage) {
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
            }else{
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
            }
            
            [UMSocialData defaultData].extConfig.wechatSessionData.url = self.href;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = self.href;
            [UMSocialData defaultData].extConfig.title = self.title;
            
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatTimeline]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                NSLog(@"%u",response.responseCode);
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
                                                                }
                                                            }];
            break;
        }
        case 3: //WechatSession
        {
            if (_isImage) {
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;
            }else{
                [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
            }
            [UMSocialData defaultData].extConfig.wechatSessionData.url = self.href;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = self.title;
            
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToWechatSession]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
																}
                                                            }];
            
            break;
        }
        case 4: //qq
        {
            if (_isImage) {
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeImage;
            }else{
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
            }
            [UMSocialData defaultData].extConfig.qqData.title = self.title;
            [UMSocialData defaultData].extConfig.qqData.url = self.href;
            [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToQQ]
                                                               content:[NSString stringWithFormat:@"%@", self.descString]
                                                                 image:self.logoImage
                                                              location:nil
                                                           urlResource:resource
                                                   presentedController:curViewController
                                                            completion:^(UMSocialResponseEntity *response) {
                                                                if (response.responseCode == UMSResponseCodeSuccess) {
                                                                    NSLog(@"分享成功");
                                                                }
                                                            }];
            
            break;
        }
        case 5: //brower
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.href]];
            
            break;
        }
        case 6: //copy url
        {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [NSString stringWithFormat:@"%@", self.href];
            
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
            
            
            [[UIApplication sharedApplication].keyWindow addSubview:HUD];
            HUD.labelText = @"已复制到剪切板";
            HUD.minShowTime = 1;
            [HUD showAnimated:YES whileExecutingBlock:^{
                NSLog(@"%@",@"do somethings....");
                
            } completionBlock:^{
                [HUD removeFromSuperview];  
                
            }];
            
//            [Tools toastNotification:@"已复制到剪切板" inView:self.view];
            
//            HUD.mode = MBProgressHUDModeCustomView;
//            HUD.label.text = @"已复制到剪切板";
//            if (self.superview) {
//                [self removeFromSuperview];
//            }
//            [HUD hideAnimated:YES afterDelay:1];
            
            break;
        }
        case 7:  //more
        {
            if (self.superview) {
                [self removeFromSuperview];
            }
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"%@ %@",self.title,self.href]] applicationActivities:nil];
            if ([activityViewController respondsToSelector:@selector(popoverPresentationController)]) {
                activityViewController.popoverPresentationController.sourceView = self;
            }

            [curViewController presentViewController:activityViewController animated:YES completion:nil];
            
            break;
        }
        default:
            break;
    }
    
    
}

-(NSString *) extractImagesUrlFromContent: (NSString *) content {
	NSRange rangeOfString = NSMakeRange(0, [content length]);
	NSString *pattern = @"<img src=\"([^\"]+)\"";
	NSError *error = nil;
	NSString *imageString = nil;
 
	NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
	NSArray *matchs = [regex matchesInString:content options:0 range:rangeOfString];
	for (NSTextCheckingResult* match in matchs) {
		imageString = [content substringWithRange:[match rangeAtIndex:1]];
		break;
	}
	return imageString;
}


- (UIViewController *)topViewControllerForViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerForViewController:navigationController.visibleViewController];
    }
    
    if (rootViewController.presentedViewController) {
        return [self topViewControllerForViewController:rootViewController.presentedViewController];
    }
    
    return rootViewController;
}

#pragma mark --- touch handle 
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _touchTrack = NO;
    UITouch* t = [touches anyObject];
    CGPoint p1 = [t locationInView:_contentView];
    if (!CGRectContainsPoint(_contentView.bounds, p1)) {
        _touchTrack = YES;
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_touchTrack) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (_touchTrack) {
        if (self.superview) {
            [self removeFromSuperview];
        }
    }else{
        [super touchesCancelled:touches withEvent:event];
    }
}

@end









