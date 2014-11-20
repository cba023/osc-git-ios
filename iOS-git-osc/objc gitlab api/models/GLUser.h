//
//  GLUser.h
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/14/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLBaseObject.h"

@interface GLUser : GLBaseObject

// id
@property (nonatomic, assign) int64_t userId;
// username
@property (nonatomic, copy) NSString *username;
// name
@property (nonatomic, copy) NSString *name;
// bio
@property (nonatomic, copy) NSString *bio;
// weibo
@property (nonatomic, copy) NSString *weibo;
// blog
@property (nonatomic, copy) NSString *blog;
// theme_id
@property (nonatomic, assign) int32_t themeId;
// state
@property (nonatomic, copy) NSString *state;
// created_at
@property (nonatomic, strong) NSString *createdAt;
// portrait
@property (nonatomic, copy) NSString *portrait;
// new_portrait
//@property (nonatomic, copy) NSString *newPortrait;
// email
@property (nonatomic, copy) NSString *email;
// private_token
@property (nonatomic, copy) NSString *private_token;
// is_admin
@property (nonatomic, getter = isAdmin) BOOL admin;
// can_create_group
@property (nonatomic) BOOL canCreateGroup;
// can_create_project
@property (nonatomic) BOOL canCreateProject;
// can_create_team
@property (nonatomic) BOOL canCreateTeam;
// follow
@property (nonatomic, strong) NSDictionary *follow;

- (BOOL)isEqualToUser:(GLUser *)user;

@end
