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

+ (NSArray *)loadExtraProjectType:(int)type onPage:(int)page;
+ (NSArray *)getProjectTreeWithID:(int64_t)projectID Branch:(NSString *)branch Path:(NSString *)path;
+ (NSString *)getFileContent:(int64_t)projectID Path:(NSString *)path Branch:(NSString *)branch;
+ (NSArray *)getOwnProjectsOnPage:(int)page;
+ (GLProject *)getASingleProject:(int64_t)projectID;

@end
