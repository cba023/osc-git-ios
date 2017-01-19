//
//  AppDelegate.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "UIColor+Util.h"

#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import <MobClick.h>

#define UMENG_APPKEY        @"5423cd47fd98c58f04000c52"
#define UMENG_APPKEY_2	 @"54c9a412fd98c5779c000752"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [UMSocialData setAppKey:@"5423cd47fd98c58f04000c52"];
    [UMSocialWechatHandler setWXAppId:@"wx850b854f6aad6764" appSecret:@"39859316eb9e664168d2af929e46f971" url:@"http://www.umeng.com/social"];
    [UMSocialQQHandler setQQWithAppId:@"1101982202" appKey:@"c7394704798a158208a74ab60104f0ba" url:@"http://www.umeng.com/social"];
    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor=UIColorFromRGB(0x272727);
    
    
    //将其PKRevealController对象作为RootViewController
 //   self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [MainViewController new];
    [self.window makeKeyAndVisible];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x0a5090)];        //UIColorFromRGB(0x1f1f1f)
        NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];               //UIColorFromRGB(0xdadada)
    } else {
        [[UINavigationBar appearance] setBackgroundColor:UIColorFromRGB(0x0a5090)];
    }
    
    /************ 友盟数据统计分析 *************/
    [MobClick startWithAppkey:UMENG_APPKEY_2 reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    [MobClick setAppVersion:XcodeAppVersion];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}


@end
