//
//  Issue.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Issue : NSObject

+ (NSMutableArray *)getIssuesWithProjectId:(int64_t)projectId;

@end
