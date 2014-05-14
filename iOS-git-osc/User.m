//
//  User.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-13.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

@import Security;
#import "User.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "KeychainItemWrapper.h"
#import "SSKeychain.h"

static NSString * const kKeyUserId = @"id";
static NSString * const kKeyUsername = @"username";
static NSString * const kKeyEmail = @"email";
static NSString * const kKeyName = @"name";
static NSString * const kKeySkype = @"skype";
static NSString * const kKeyLinkedin = @"linkedin";
static NSString * const kKeyTwitter = @"twitter";
static NSString * const kKeyProvider = @"provider";
static NSString * const kKeyState = @"state";
static NSString * const kKeyCreatedAt = @"created_at";
static NSString * const kKeyBio = @"bio";
static NSString * const kKeyExternUid = @"extern_uid";
static NSString * const kKeyThemeId = @"theme_id";
static NSString * const kKeyColorSchemeId = @"color_scheme_id";
static NSString * const kKeyAdmin = @"is_admin";
static NSString * const kKeyProtrait = @"protrait";

@implementation User

+ (void)loginWithAccount:(NSString *)account andPassword:(NSString *)password {
    __block BOOL done = NO;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        GLUser *user = responseObject;
        if (responseObject == nil){
            NSLog(@"Request failed");
        } else {
            [SSKeychain setPassword:@(user.userId)
                         forService:kKeyUserId
                            account:user.username];
            
            NSString *retrieveuuid = [SSKeychain passwordForService:@"com.yourapp.yourcompany"account:@"user"];
            NSLog(@"%@", retrieveuuid);
            NSLog(@"username: %@, name = %@", user.username, user.name);
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"Request failed");
        }
        done = YES;
    };
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] loginToHost:@"http://git.oschina.net"
                                                                 email:@"aeternchan@gmail.com"
                                                              password:@"27inoschina"
                                                               success:success
                                                               failure:failure];
    //[[GLGitlabApi sharedInstance] privateToken];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

}

@end
