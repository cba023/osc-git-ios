//
//  GLGitlabApi+Session.h
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/22/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLGitlabApi.h"


@interface GLGitlabApi (Session)

- (GLNetworkOperation *)loginToHost:(NSString *)host
                              email:(NSString *)email
                           password:(NSString *)password
                            success:(GLGitlabSuccessBlock)successBlock
                            failure:(GLGitlabFailureBlock)failureBlock;

@end
