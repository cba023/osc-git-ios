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

+ (NSArray *)getMilestonesForProjectId:(int64_t)projectId page:(int)page
{
    __block BOOL done = NO;
    __block NSMutableArray *milestones;
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            milestones = responseObject;
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getAllIssuesForProjectId:projectId
                                                                       privateToken:privateToken
                                                                               page:page
                                                                   withSuccessBlock:success
                                                                    andFailureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return milestones;
}

+ (void)createIssue:(GLIssue *)issue
{
    __block BOOL done = NO;
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            NSLog(@"success");
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] createIssue:issue
                                                          privateToken:privateToken
                                                      withSuccessBlock:success
                                                       andFailureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}


@end
