//
//  GLGitlabApi+Session.h
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/22/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLGitlabApi.h"


@interface GLGitlabApi (Session)

- (GLNetworkOperation *)loginWithEmail:(NSString *)email
                              Password:(NSString *)password
                               Success:(GLGitlabSuccessBlock)successBlock
                               Failure:(GLGitlabFailureBlock)failureBlock;

@end
