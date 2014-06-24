//
//  Project.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-23.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Project.h"
#import "GLGitlab.h"

@implementation Project

+ (NSArray *)getPopularProject {
    __block BOOL done = NO;
    __block NSArray *array;
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getPopularProjectsSuccess:
                              ^(id responseObject) {
                                  if (responseObject == nil) {
                                      NSLog(@"Request failed");
                                  } else {
                                      array = responseObject;
                                  }
                                  done = YES;
                              }
                                                                             failure:
                              ^(NSError *error) {
                                  if (error != nil) {
                                      NSLog(@"Request failed");
                                  } else {
                                      NSLog(@"error == nil");
                                  }
                                  done = YES;
                              }];
#if 1
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
#endif
    return array;
}


@end
