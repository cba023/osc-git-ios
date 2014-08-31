//
//  Project.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-23.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLProject;

@interface Project : NSObject

+ (NSArray *)getProjectTreeWithID:(int64_t)projectID Branch:(NSString *)branch Path:(NSString *)path;
+ (NSString *)getFileContent:(int64_t)projectID Path:(NSString *)path Branch:(NSString *)branch;

+ (GLProject *)getASingleProject:(int64_t)projectID;

+ (NSString *)loadReadme:(int64_t)projectID;

+ (NSArray *)getTeamMembersForProjectId:(int64_t)projectId;

@end
