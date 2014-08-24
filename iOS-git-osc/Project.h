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

+ (NSArray *)loadExtraProjectType:(NSInteger)type onPage:(NSUInteger)page;
+ (NSArray *)getOwnProjectsOnPage:(NSUInteger)page;
+ (NSArray *)getStarredProjectsForUser:(int64_t)userID;
+ (NSArray *)getWatchedProjectsForUser:(int64_t)userID;
+ (GLProject *)getASingleProject:(int64_t)projectID;
+ (NSArray *)searchProjects:(NSString *)query page:(NSInteger)page;
+ (NSArray *)getProjectsForLanguage:(NSInteger)languageID page:(NSInteger)page;

+ (NSString *)loadReadme:(int64_t)projectID;

+ (NSArray *)getLanguagesList;

+ (NSArray *)getTeamMembersForProjectId:(int64_t)projectId;

@end
