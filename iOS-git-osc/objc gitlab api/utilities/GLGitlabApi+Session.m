//
//  GLGitlabApi+Session.m
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/22/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLGitlabApi+Session.h"
#import "GLGitlabApi+Private.h"
#import "GLUser.h"

static NSString * const kLoginRoute = @"/session";

// Request Keys
static NSString * const kLoginUseremailKey = @"email";
static NSString * const kLoginPasswordKey = @"password";

// Response Keys
static NSString *const kPrivateTokenKey = @"private_token";

@implementation GLGitlabApi (Session)


- (GLNetworkOperation *)loginWithEmail:(NSString *)email
                              Password:(NSString *)password
                               Success:(GLGitlabSuccessBlock)successBlock
                               Failure:(GLGitlabFailureBlock)failureBlock
{
    NSDictionary *params = @{ kLoginUseremailKey: email, kLoginPasswordKey: password };
    NSMutableURLRequest *request = [self requestForEndPoint:kLoginRoute
                                                     method:GLNetworkOperationPostMethod];
    NSError *error;
    request.HTTPBody = [self urlEncodeParams:params];
    if (error) {
        NSLog(@"Error serializing login params: %@", error.localizedDescription);
        failureBlock(error);
        return nil;
    }
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *responseObject) {
        self.privateToken = responseObject[kPrivateTokenKey];
        GLUser *user = [[GLUser alloc] initWithJSON:responseObject];
        successBlock(user);
    };
    
    GLNetworkOperationFailureBlock localFailureBlock = ^(NSError *error, NSInteger httpStatus, NSData *responseData) {
        failureBlock(error);
    };
    
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}
@end
