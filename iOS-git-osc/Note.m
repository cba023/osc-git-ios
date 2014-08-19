//
//  Note.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Note.h"
#import "GLGitlab.h"
#import "Tools.h"

@implementation Note

+ (NSMutableArray *)getNotesForIssue:(GLIssue *)issue page:(int)page
{
    __block BOOL done = NO;
    __block NSMutableArray *notes;
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            notes = responseObject;
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getAllNotesForIssue:issue
                                                                  privateToken:privateToken
                                                                          page:page
                                                              withSuccessBlock:success
                                                               andFailureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return notes;
}

+ (BOOL)createNoteForIssue:(GLIssue *)issue body:(NSString *)body
{
    __block BOOL done = NO;
    __block BOOL sended = NO;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            sended = YES;
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] createNoteForIssue:issue
                                                                     withBody:body
                                                                 successBlock:success
                                                              andFailureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    return sended;
}


@end
