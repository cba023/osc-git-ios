//
//  GLEvent.m
//  objc gitlab api
//
//  Created by Jon Staff on 1/28/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLEvent.h"

static NSString * const kKeyId = @"id";
static NSString * const kKeyTargetType = @"target_type";
static NSString * const kKeyTargetId = @"target_id";
static NSString * const kKeyTitle = @"title";
static NSString * const kKeyData = @"data";
static NSString * const kKeyProjectId = @"project_id";
static NSString * const kKeyCreatedAt = @"created_at";
static NSString * const kKeyUpdatedAt = @"updated_at";
static NSString * const kKeyAction = @"action";
static NSString * const kKeyAuthorId = @"author_id";
static NSString * const kKeyPublic = @"public";
static NSString * const kKeyProject = @"project";
static NSString * const kKeyAuthor = @"author";
static NSString * const kKeyNote = @"note";

@implementation GLEvent

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _id = [[self checkForNull:json[kKeyId]] longLongValue];
        _targetId = [[self checkForNull:json[kKeyTargetId]] longLongValue];
        _targetType = [self checkForNull:json[kKeyTargetType]];
        _title = [self checkForNull:json[kKeyTitle]];
        _data = json[kKeyData];
        if ((id)_data == [NSNull null]) {
            _data = nil;
        }
        _projectId = [[self checkForNull:json[kKeyProjectId]] longLongValue];
        _createdAt = [self checkForNull:json[kKeyCreatedAt]];
        _updatedAt = [self checkForNull:json[kKeyUpdatedAt]];
        _action = [[self checkForNull:json[kKeyAction]] intValue];
        _authorId = [[self checkForNull:json[kKeyAuthorId]] longLongValue];
        _public = [[self checkForNull:json[kKeyPublic]] boolValue];
        _project = [[GLProject alloc] initWithJSON:json[kKeyProject]];
        _author = [[GLUser alloc] initWithJSON:json[kKeyAuthor]];
        _note = [self checkForNull:json[kKeyNote]];
    }
    
    return self;
}
- (NSString *)description
{
    NSString *description = @"";
#if 0
    switch (self.action) {
        case 1:
            description = [NSString stringWithFormat:@"%@在项目%@ / %@创建了Issue", self.author.name, self.project.owner.name, self.project.name];
            break;
            
        case 2:
        default:
            break;
    }
#else
    if (self.action == 5) {
        description = [NSString stringWithFormat:@"%@推送到项目%@ / %@的master分支", self.author.name, self.project.owner.name, self.project.name];
    } else if (self.action == 1) {
        description = [NSString stringWithFormat:@"%@在项目%@ / %@创建了Issue", self.author.name, self.project.owner.name, self.project.name];
    } else if (self.action == 3) {
        description = [NSString stringWithFormat:@"%@关闭了项目%@ / %@的Issue", self.author.name, self.project.owner.name, self.project.name];
    } else if (self.action == 6) {
        description = [NSString stringWithFormat:@"%@评论了项目%@ / %@的Issue", self.author.name, self.project.owner.name, self.project.name];
    }
    return description;
#endif
}

@end
