//
//  Issue.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Issue.h"
#import "GLGitlab.h"
#import "Tools.h"

@implementation Issue

+ (NSAttributedString *)generateIssueInfo:(GLIssue *)issue
{
    NSString *timeInterval = [Tools intervalSinceNow:issue.createdAt];
    NSString *issueInfo = [NSString stringWithFormat:@"#%lld by %@ - %@", issue.issueIid, issue.author.name, timeInterval];
    NSAttributedString *attrIssueInfo = [Tools grayString:issueInfo fontName:nil fontSize:14];
    
    return attrIssueInfo;
}


@end
