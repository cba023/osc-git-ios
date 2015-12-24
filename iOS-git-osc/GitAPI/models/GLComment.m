//
//  GLComment.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/14.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "GLComment.h"

static NSString * const kKeyForCommentId = @"id";
static NSString * const kKeyForCreatedAt = @"created_at";
static NSString * const kKeyForProjectId = @"project_id";
static NSString * const kKeyForCommitId = @"commit_id";
static NSString * const kKeyForAuthor = @"author";
static NSString * const kKeyForNote = @"note";

@implementation GLComment

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _commentID = [json[kKeyForCommentId] longLongValue];
        
        NSString *dateString;
        if (json[kKeyForCreatedAt]) {
            dateString = [self checkForNull:json[kKeyForCreatedAt]];
            _creatTime = dateString;
        }
        
        _projectID = [json[kKeyForProjectId] longLongValue];
        _commitId = [self checkForNull:json[kKeyForCommitId]];
        _author = [self checkForNull:json[kKeyForAuthor]] ? [[GLUser alloc] initWithJSON:json[kKeyForAuthor]] : nil;
        _noteString = [self checkForNull:json[kKeyForNote]];
    }
    
    return self;
}

- (BOOL)isEqualToComment:(GLComment *)comment
{
    if (self == comment) {
        return YES;
    }
    if (comment == nil) {
        return NO;
    }
    if (self.commitId != comment.commitId && ![self.commitId isEqualToString:comment.commitId])
        return NO;
    if (self.creatTime != comment.creatTime && ![self.creatTime isEqualToString:comment.creatTime])
        return NO;
    if (self.noteString != comment.noteString && ![self.noteString isEqualToString:comment.noteString])
        return NO;
    return YES;
}

@end
