//
//  GLUser.m
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/14/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLUser.h"
#import "GLGitlabApi.h"

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
static NSString * const kKeyNewPortrait = @"new_portrait";
static NSString * const kKeyEmail = @"email";
static NSString * const kKeyPrivate_token = @"private_token";
static NSString * const kKeyAdmin = @"is_admin";
static NSString * const kKeyCanCreateGroup = @"can_create_group";
static NSString * const kKeyCanCreateProject = @"can_create_project";
static NSString * const kKeyCanCreateTeam = @"can_create_team";
static NSString * const kKeyFollow = @"follow";

@implementation GLUser

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _userId = [json[kKeyUserId] longLongValue];
        _username = [self checkForNull:json[kKeyUsername]];
        _name = [self checkForNull:json[kKeyName]];
        _bio = [self checkForNull:json[kKeyBio]];
        _weibo = [self checkForNull:json[kKeyWeibo]];
        _blog = [self checkForNull:json[kKeyBlog]];
        _themeId = [json[kKeyThemeId] intValue];
        _createdAt = [self checkForNull:json[kKeyCreatedAt]];
        //_createdAt = [[[GLGitlabApi sharedInstance] gitLabDateFormatter] dateFromString:json[kKeyCreatedAt]];
        _state = [self checkForNull:json[kKeyState]];
        _portrait = [self checkForNull:json[kKeyNewPortrait]];
        //_newPortrait = [self checkForNull:json[kKeyNewPortrait]];
        _email = [self checkForNull:json[kKeyEmail]];
        _private_token = [self checkForNull:json[kKeyPrivate_token]];
        _admin = [json[kKeyAdmin] boolValue];
        _canCreateGroup = [json[kKeyCanCreateGroup] boolValue];
        _canCreateProject = [json[kKeyCanCreateProject] boolValue];
        _canCreateTeam = [json[kKeyCanCreateTeam] boolValue];
        _follow = json[kKeyFollow];
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;
    
    return [self isEqualToUser:other];
}

- (BOOL)isEqualToUser:(GLUser *)user {
    if (self == user)
        return YES;
    if (user == nil)
        return NO;
    if (self.userId != user.userId)
        return NO;
    if (self.username != user.username && ![self.username isEqualToString:user.username])
        return NO;
    if (self.name != user.name && ![self.name isEqualToString:user.name])
        return NO;
    if (self.bio != user.bio && ![self.bio isEqualToString:user.bio])
        return NO;
    if (self.weibo != user.weibo && ![self.weibo isEqualToString:user.weibo])
        return NO;
    if (self.blog != user.blog && ![self.blog isEqualToString:user.blog])
        return NO;
    if (self.themeId != user.themeId)
        return NO;
    if (self.state != user.state && ![self.state isEqualToString:user.state])
        return NO;
    //if (self.createdAt != user.createdAt && ![self.createdAt isEqualToDate:user.createdAt])
    //    return NO;
    if (self.portrait != user.portrait && ![self.portrait isEqualToString:user.portrait])
        return NO;
    if (self.admin != user.admin)
        return NO;
    if (self.canCreateGroup != user.canCreateGroup)
        return NO;
    if (self.canCreateProject != user.canCreateProject)
        return NO;
    if (self.canCreateTeam != user.canCreateTeam)
        return NO;
    
    return YES;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.userId=%qi", self.userId];
    [description appendFormat:@", self.username=%@", self.username];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.bio=%@", self.bio];
    [description appendFormat:@", self.weibo=%@", self.weibo];
    [description appendFormat:@", self.blog=%@", self.blog];
    [description appendFormat:@", self.themeId=%i", self.themeId];
    [description appendFormat:@", self.state=%@", self.state];
    [description appendFormat:@", self.createdAt=%@", self.createdAt];
    [description appendFormat:@", self.portrait=%@", self.portrait];
    [description appendFormat:@", self.private_token=%@", self.private_token];
    [description appendFormat:@", self.admin=%d", self.admin];
    [description appendFormat:@", self.canCreateGroup=%d", self.canCreateGroup];
    [description appendFormat:@", self.canCreateProject=%d", self.canCreateProject];
    [description appendFormat:@", self.canCreateTeam=%d", self.canCreateTeam];
    [description appendString:@">"];
    return description;
}

- (NSDictionary *)jsonRepresentation
{
//    NSDateFormatter *formatter = [[GLGitlabApi sharedInstance] gitLabDateFormatter];
//    NSNull *null = (id)[NSNull null];
    NSString *null = @"";

    return @{
             kKeyUserId: @(_userId),
             kKeyUsername: _username ?: null,
             kKeyName: _name ?: null,
             kKeyBio: _bio ?: null,
             kKeyWeibo: _weibo ?: null,
             kKeyBlog: _blog ?: null,
             kKeyThemeId: @(_themeId),
             kKeyState: _state ?: null,
             kKeyCreatedAt: _createdAt ?: null,                         //[formatter stringFromDate:_createdAt] ?: null,
             kKeyThemeId: @(_themeId),
             //kKeyAdmin: @(_admin),
             kKeyNewPortrait: _portrait ?: null,
             kKeyFollow: _follow ?: null
             };
}

- (NSDictionary *)jsonCreateRepresentation
{
    NSNull *null = [NSNull null];
    return @{
             kKeyUserId: @(_userId),
             kKeyUsername: _username,
             kKeyName: _name ?: null,
             kKeyState: _state ?: null,
             kKeyBio: _bio ?: null,
             kKeyWeibo: _weibo ?: null,
             kKeyBlog: _blog ?: null,
             kKeyThemeId: @(_themeId),
             kKeyState: _state ?: null,
             kKeyCreatedAt: _createdAt ?: null,
             kKeyPortrait: _portrait ?: null,
             kKeyAdmin: @(_admin),
             kKeyCanCreateGroup: @(_canCreateGroup),
             kKeyCanCreateProject: @(_canCreateProject),
             kKeyCanCreateTeam: @(_canCreateTeam)
             };
}

@end
