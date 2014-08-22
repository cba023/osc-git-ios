//
//  GLGitLabApi(Events).h
//  testAPI
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLGitlabApi.h"

@interface GLGitlabApi (Events)

- (GLNetworkOperation *)getEventsWithPrivateToken:(NSString *)privateToken
                                             page:(NSInteger)page
                                          success:(GLGitlabSuccessBlock)successBlock
                                          failure:(GLGitlabFailureBlock)failureBlock;

- (GLNetworkOperation *)getUserEvents:(int64_t)userId
                                 page:(NSInteger)page
                              success:(GLGitlabSuccessBlock)successBlock
                              failure:(GLGitlabFailureBlock)failureBlock;

@end
