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
static NSString * const kKeyEvents = @"events";
static NSString * const kKeyNote = @"note";
static NSString * const kKeyIssue = @"issue";
static NSString * const kKeyIId = @"iid";
static NSString * const kKeyPullRequest = @"pull_request";


////
static NSString * const kKeyRef = @"ref";
static NSString * const kKeyCommits = @"commits";
static NSString * const kKeyTotalCommitCount = @"total_commits_count";

@implementation GLEventData

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _ref = [self checkForNull:json[kKeyRef]];
        _totalCommitCount = [[self checkForNull:json[kKeyTotalCommitCount]] integerValue];
        _dataCommits = [NSMutableArray new];
        
        if (json[kKeyCommits]) {
            [json[kKeyCommits] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GLCommit *commit = [[GLCommit alloc] initWithJSON:obj];
                
                [_dataCommits addObject:commit];
            }];
            
        }
    }
    
    return self;
}

@end

@implementation GLEvent

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _eventID = [[self checkForNull:json[kKeyId]] longLongValue];
        _targetId = [[self checkForNull:json[kKeyTargetId]] longLongValue];
        _targetType = [self checkForNull:json[kKeyTargetType]];
        _title = [self checkForNull:json[kKeyTitle]];
        _data = [self checkForNull:json[kKeyData]];
        if (json[kKeyData]) {
//            _eventData = [[GLEventData alloc] initWithJSON:json[kKeyData]];
        }
        
#if 0
        if ((id)_data == [NSNull null]) {
            _data = nil;
        }
#endif
        _projectId = [[self checkForNull:json[kKeyProjectId]] longLongValue];
        _createdAt = [self checkForNull:json[kKeyCreatedAt]];
        _updatedAt = [self checkForNull:json[kKeyUpdatedAt]];
        _action = [[self checkForNull:json[kKeyAction]] intValue];
        _authorId = [[self checkForNull:json[kKeyAuthorId]] longLongValue];
        _isPublic = [[self checkForNull:json[kKeyPublic]] boolValue];
        _project = [[GLProject alloc] initWithJSON:json[kKeyProject]];
        _author = [[GLUser alloc] initWithJSON:json[kKeyAuthor]];
        _events = [self eventsInitWithJson:json[kKeyEvents]];
    }
    
    return self;
}

- (NSDictionary *)eventsInitWithJson:(NSDictionary *)json
{
    NSDictionary *note = [self checkForNull:json[kKeyNote]];
    NSDictionary *issue = [self checkForNull:json[kKeyIssue]];
    NSDictionary *pullRequest = [self checkForNull:json[kKeyPullRequest]];
    
    return @{
             kKeyNote: note ?: @{},
             kKeyIssue: issue ?: @{},
             kKeyPullRequest: pullRequest ?: @{}
             };
}

- (id)ifEmptyThanNull:(NSDictionary *)json
{
    if ([json count] == 0) {
        return [NSNull null];
    }
    
    return json;
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

- (NSDictionary *)jsonRepresentation
{
    //id null = (id)[NSNull null];
    NSDictionary *null = @{};
    
    return @{
             kKeyId: @(_eventID),
             kKeyTargetId: @(_targetId),
             kKeyTargetType: _targetType ?: null,
             kKeyTitle: _title ?: null,
             kKeyAction: @(_action),
             kKeyData: _data ?: null,
             kKeyProjectId: @(_projectId),
             kKeyCreatedAt: _createdAt ?: null,
             kKeyAuthorId: @(_authorId),
             kKeyPublic: @(_isPublic),
             kKeyProject: [_project jsonRepresentation],
             kKeyAuthor: [_author jsonRepresentation],
             kKeyEvents: _events ?: null,
             };
}


@end
