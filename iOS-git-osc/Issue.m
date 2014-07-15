//
//  Issue.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Issue.h"
#import "GLGitlab.h"

@implementation Issue

+ (NSMutableArray *)getIssuesWithProjectId:(int64_t)projectId {
    __block BOOL done = NO;
    __block NSMutableArray *issues;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            issues = responseObject;
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
                                                                   withSuccessBlock:success
                                                                    andFailureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return issues;
}

@end
