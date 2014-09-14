//
//  Issue.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLIssue;

@interface Issue : NSObject

+ (NSAttributedString *)generateIssueInfo:(GLIssue *)issue;

+ (NSArray *)getMilestonesForProjectId:(int64_t)projectId page:(int)page;

+ (void)createIssue:(GLIssue *)issue;


@end
