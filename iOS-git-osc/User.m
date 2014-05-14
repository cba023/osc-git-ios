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
            KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:@"User" accessGroup:nil];
            NSNumber *userId, *themeId, *colorSchemeId, *isAdmin;
            userId = [NSNumber numberWithLongLong: user.userId];
            themeId =[NSNumber numberWithInt: user.themeId];
            colorSchemeId = [NSNumber numberWithInt: user.colorSchemeId];
            isAdmin = [NSNumber numberWithBool: user.isAdmin];
            
            [keychainItem setObject:userId forKey:kKeyUserId];
            [keychainItem setObject:user.username forKey:kKeyUsername];
            [keychainItem setObject:user.email forKey:kKeyEmail];
            [keychainItem setObject:user.name forKey:kKeyName];
            [keychainItem setObject:user.skype forKey:kKeySkype];
            [keychainItem setObject:user.linkedin forKey:kKeyLinkedin];
            [keychainItem setObject:user.twitter forKey:kKeyTwitter];
            [keychainItem setObject:user.provider forKey:kKeyProvider];
            [keychainItem setObject:user.state forKey:kKeyState];
            [keychainItem setObject:user.createdAt forKey:kKeyCreatedAt];
            [keychainItem setObject:user.bio forKey:kKeyBio];
            [keychainItem setObject:user.externUid forKey:kKeyExternUid];
            [keychainItem setObject:themeId forKey:kKeyThemeId];
            [keychainItem setObject:colorSchemeId forKey:kKeyColorSchemeId];
            [keychainItem setObject:isAdmin forKey:kKeyAdmin];
            [keychainItem setObject:user.protrait forKey:kKeyProtrait];
            
            
            NSLog(@"username: %@, name = %@, email = %@", user.username, user.name, user.email);
            NSLog(@"%@", [Tools md5: user.email]);
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
