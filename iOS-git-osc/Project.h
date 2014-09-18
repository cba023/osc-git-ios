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

+ (NSString *)getFileContent:(int64_t)projectID Path:(NSString *)path Branch:(NSString *)branch;

+ (NSString *)loadReadme:(int64_t)projectID;


@end
