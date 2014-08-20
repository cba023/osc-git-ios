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

+ (NSArray *)loadExtraProjectType:(NSInteger)type onPage:(NSUInteger)page {
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
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getExtraProjectsType:type
                                                                           page:page
                                                                        success:success
                                                                        failure:failure];
                              
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return array;
}


+ (NSArray *)getProjectTreeWithID:(int64_t)projectID Branch:(NSString *)branch Path:(NSString *)path {
    __block BOOL done = NO;
    __block NSArray *array;
    NSString *privateToken = [Tools getPrivateToken];
    
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
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getRepositoryTreeForProjectId:projectID
                                                                            privateToken:privateToken
                                                                                    path:path
                                                                              branchName:branch
                                                                            successBlock:success
                                                                            failureBlock:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return array;
}

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

+ (NSArray *)getOwnProjectsOnPage:(NSUInteger)page
{
    __block BOOL done = NO;
    __block NSArray *array;
    NSString *privateToken = [Tools getPrivateToken];
    
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
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getUsersProjectsWithPrivateToken:privateToken
                                                                                     onPage:page
                                                                                    success:success
                                                                                    failure:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return array;
}

#if 0
+ (NSArray *)getStarredProjectsOnPage:(NSUInteger)page
{
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
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getUsersProjectsWithPrivateToken:privateToken
                                                                                     onPage:page
                                                                                    success:success
                                                                                    failure:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return array;
}
#endif

+ (GLProject *)getASingleProject:(int64_t)projectID
{
    __block BOOL done = NO;
    __block GLProject *project;
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            project = responseObject;
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
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getProjectWithId:projectID
                                                               privateToken:privateToken
                                                                    success:success
                                                                    failure:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return project;
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

+ (NSArray *)getTeamMembersForProjectId:(int64_t)projectId
{
    __block BOOL done = NO;
    __block NSArray *members;
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            members = responseObject;
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
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getProjectTeamUsers:projectId
                                                                  privateToken:privateToken
                                                                       success:success
                                                                       failure:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return members;
}

+ (NSArray *)loadProjectsType:(NSInteger)type page:(NSUInteger)page
{
    if (type < 3) {
        return [Project loadExtraProjectType:type onPage:page];
    } else if (type == 3) {
        return [Project getOwnProjectsOnPage:1];
    //} else if (type == 4) {
        //return [self.projectsArray addObjectsFromArray:[Project ]];
    } else {
        return [Project getOwnProjectsOnPage:1];
        //return [self.projectsArray addObjectsFromArray:[Project ]];
    }
}



@end
