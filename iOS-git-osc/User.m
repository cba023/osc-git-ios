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
#import "SSKeychain.h"

static NSString * const kKeyUserId = @"id";
static NSString * const kKeyUsername = @"username";
static NSString * const kKeyName = @"name";
static NSString * const kKeyBio = @"bio";
static NSString * const kKeyWeibo = @"weibo";
static NSString * const kKeyBlog = @"blog";
static NSString * const kKeyThemeId = @"theme_id";
static NSString * const kKeyCreatedAt = @"created_at";
static NSString * const kKeyState = @"state";
static NSString * const kKeyPortrait = @"new_portrait";
static NSString * const kKeyPrivateToken = @"private_token";
static NSString * const kKeyAdmin = @"is_admin";
static NSString * const kKeyCanCreateGroup = @"can_create_group";
static NSString * const kKeyCanCreateProject = @"can_create_project";
static NSString * const kKeyCanCreateTeam = @"can_create_team";
static NSString * const kKeyFollow = @"follow";

@implementation User

+ (void)loginWithAccount:(NSString *)account andPassword:(NSString *)password {
    __block BOOL done = NO;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        GLUser *user = responseObject;
        if (responseObject == nil){
            NSLog(@"Request failed");
        } else {
            [User saveUserInformation:user];
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        }
        done = YES;
    };
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] loginWithEmail:account Password:password Success:success Failure:failure];
    //[[GLGitlabApi sharedInstance] privateToken];
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

+ (void)saveUserInformation:(GLUser *)user {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:user.userId forKey:kKeyUserId];
    [userDefaults setObject:user.username forKey:kKeyUsername];
    [userDefaults setObject:user.name forKey:kKeyName];
    [userDefaults setObject:user.bio forKey:kKeyBio];
    [userDefaults setObject:user.weibo forKey:kKeyWeibo];
    [userDefaults setObject:user.blog forKey:kKeyBlog];
    [userDefaults setInteger:user.themeId forKey:kKeyThemeId];
    [userDefaults setObject:user.state forKey:kKeyState];
    [userDefaults setObject:user.createdAt forKey:kKeyCreatedAt];
    [userDefaults setObject:user.portrait forKey:kKeyPortrait];
    [userDefaults setObject:user.private_token forKey:kKeyPrivateToken];
    [userDefaults setBool:user.admin forKey:kKeyAdmin];
    [userDefaults setBool:user.canCreateGroup forKey:kKeyCanCreateGroup];
    [userDefaults setBool:user.canCreateProject forKey:kKeyCanCreateProject];
    [userDefaults setBool:user.canCreateTeam forKey:kKeyCanCreateTeam];
    [userDefaults setObject:user.follow forKey:kKeyFollow];
}

+ (void)saveUserName:(NSString *)username andPassword:(NSString *)password {
    [SSKeychain setPassword:password forService:@"password" account:username];
}

@end