//
//  User.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-13.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLUser;

static NSString * const kKeyUserId = @"id";
static NSString * const kKeyUsername = @"username";
static NSString * const kKeyName = @"name";
static NSString * const kKeyBio = @"bio";
static NSString * const kKeyWeibo = @"weibo";
static NSString * const kKeyBlog = @"blog";
static NSString * const kKeyThemeId = @"theme_id";
static NSString * const kKeyCreatedAt = @"created_at";
static NSString * const kKeyState = @"state";
static NSString * const kKeyPortrait = @"portrait";
static NSString * const kKeyPrivate_token = @"private_token";
static NSString * const kKeyAdmin = @"is_admin";
static NSString * const kKeyCanCreateGroup = @"can_create_group";
static NSString * const kKeyCanCreateProject = @"can_create_project";
static NSString * const kKeyCanCreateTeam = @"can_create_team";

@interface User : NSObject

+ (void)loginWithAccount:(NSString *)account andPassword:(NSString *)password;
+ (void)saveUserName:(NSString *)username andPassword:(NSString *)password;
+ (void)saveUserInformation:(GLUser *)user;

@end
