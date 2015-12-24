//
//  GLEvent.h
//  objc gitlab api
//
//  Created by Jon Staff on 1/28/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLBaseObject.h"
#import "GLUser.h"
#import "GLProject.h"
#import "GLCommit.h"

@interface GLEventData : GLBaseObject

@property (nonatomic, assign) NSInteger totalCommitCount;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, strong) NSMutableArray *dataCommits;

@end

@interface GLEvent : GLBaseObject

// id
@property (nonatomic, assign) int64_t eventID;
// target_type
@property (nonatomic, copy) NSString *targetType;
// target_id
@property (nonatomic, assign) int64_t targetId;
// title
@property (nonatomic, copy) NSString *title;
// data
@property (nonatomic, strong) NSDictionary *data;

//@property (nonatomic, strong) GLEventData *eventData;
// project_id
@property (nonatomic, assign) int64_t projectId;
// created_at
@property (nonatomic, copy) NSString *createdAt;
// updated_at
@property (nonatomic, copy) NSString *updatedAt;
// action
@property (nonatomic, assign) int action;
// author_id
@property (nonatomic, assign) int64_t authorId;
// public
@property (nonatomic) BOOL isPublic;
// project
@property (nonatomic, strong) GLProject *project;
// user
@property (nonatomic, strong) GLUser *author;
// events
@property (nonatomic, strong) NSDictionary *events;

@end
