//
//  GLGitLabApi(Events).h
//  testAPI
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLGitlabApi.h"

@interface GLGitlabApi (Events)

- (GLNetworkOperation *)getEventsWithPrivateToken:(NSString *)private_token
                                             page:(int)page
                                          success:(GLGitlabSuccessBlock)successBlock
                                          failure:(GLGitlabFailureBlock)failureBlock;

@end
