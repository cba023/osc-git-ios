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

+ (NSArray *)loadExtraProjectType:(int)type OnPage:(int)page {
    __block BOOL done = NO;
    __block NSArray *array;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            array = responseObject;
        }
        done = YES;
    };
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"Request failed");
        } else {
            NSLog(@"error == nil");
        }
        done = YES;
    };
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getExtraProjectsType:type
                                                                           Page:page
                                                                        Success:success
                                                                        Failure:failure];
                              
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return array;
}


+ (NSArray *)getProjectTreeWithID:(int64_t)projectID Branch:(NSString *)branch Path:(NSString *)path {
    __block BOOL done = NO;
    __block NSArray *array;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil){
            NSLog(@"Request failed");
        } else {
            array = responseObject;
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"Request failed");
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getRepositoryTreeForProjectId:projectID
                                                                                    path:path
                                                                              branchName:branch
                                                                        withSuccessBlock:success
                                                                         andFailureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return array;
}

+ (NSString *)getFileContent:(int64_t)projectID Path:(NSString *)path Branch:(NSString *)branch {
    __block BOOL done = NO;
    __block NSString *content;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil){
            NSLog(@"Request failed");
        } else {
            content = [Tools decodeBase64String:[responseObject description]];
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getFileContentFromProject:projectID
                                                                                path:path
                                                                          branchName:branch
                                                                    withSuccessBlock:success
                                                                     andFailureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return content;
}

@end
