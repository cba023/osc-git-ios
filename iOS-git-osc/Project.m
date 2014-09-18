//
//  Project.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-23.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Project.h"
#import "GLGitlab.h"
#import "Tools.h"

@implementation Project

+ (NSString *)getFileContent:(int64_t)projectID Path:(NSString *)path Branch:(NSString *)branch {
    __block BOOL done = NO;
    __block GLBlob *blob;
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil){
            NSLog(@"Request failed");
        } else {
            blob = responseObject;
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getFileContentFromProject:projectID
                                                                        privateToken:privateToken
                                                                                path:path
                                                                          branchName:branch
                                                                        successBlock:success
                                                                        failureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return blob.content;
}

+ (NSString *)loadReadme:(int64_t)projectID
{
    __block BOOL done = NO;
    __block NSString *readme;
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            readme = ((GLBlob *)responseObject).content;
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] loadReadmeForProjectID:projectID
                                                                     privateToken:privateToken
                                                                          success:success
                                                                          failure:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return readme;
}



@end
