//
//  GLGitlabApi+Files.h
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 2/13/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLGitlabApi.h"

@interface GLGitlabApi (Files)

- (GLNetworkOperation *)getRepositoryTreeForProjectId:(int64_t)projectId
                                         privateToken:(NSString *)privateToken
                                                 path:(NSString *)path
                                           branchName:(NSString *)branch
                                         successBlock:(GLGitlabSuccessBlock)success
                                         failureBlock:(GLGitlabFailureBlock)failure;

- (GLNetworkOperation *)getFileContentFromProject:(int64_t)projectId
                                     privateToken:(NSString *)privateToken
                                             path:(NSString *)path
                                       branchName:(NSString *)branch
                                     successBlock:(GLGitlabSuccessBlock)success
                                     failureBlock:(GLGitlabFailureBlock)failure;;


@end
