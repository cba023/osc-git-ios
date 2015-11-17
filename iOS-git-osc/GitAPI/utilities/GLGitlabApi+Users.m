//
//  GLGitlabApi+Users.m
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/22/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLGitlabApi+Users.h"
#import "GLGitlabApi+Private.h"
#import "GLUser.h"

// End points
static NSString * const kUserEndpoint = @"/users";
static NSString * const kSingleUserEndpoint = @"/users/%llu";
static NSString * const kReceivingInfoEndpoint = @"/users/%llu/address";

// Parameter Keys
static NSString * const kPageParam = @"page";
static NSString * const kPerPageParam = @"per_page";
static NSString * const kUid = @"uid";
static NSString * const kPrivateToken = @"private_token";
static NSString * const kName = @"name";
static NSString * const kPhoneNumber = @"tel";
static NSString * const kAddress = @"address";
static NSString * const kExtraInfo = @"comment";

@implementation GLGitlabApi (Users)
#pragma mark - User Methods

- (GLNetworkOperation *)getUsers:(int64_t)pageNumber
                       batchSize:(int64_t)batchSize
                         success:(GLGitlabSuccessBlock)successBlock
                         failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kUserEndpoint
                                                     params:@{ kPageParam: @(pageNumber), kPerPageParam: @(batchSize) }
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLUser class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getUser:(int64_t)userId
                        success:(GLGitlabSuccessBlock)successBlock
                        failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kSingleUserEndpoint, userId]
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLUser class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];

    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)createUser:(GLUser *)user
                           success:(GLGitlabSuccessBlock)successBlock
                           failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kUserEndpoint method:GLNetworkOperationPostMethod];
    request.HTTPBody = [self urlEncodeParams:[user jsonCreateRepresentation]];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLUser class]
                                                                                 successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)updateUser:(GLUser *)user
                           success:(GLGitlabSuccessBlock)successBlock
                           failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kUserEndpoint
                                                     method:GLNetworkOperationPutMethod];
    request.HTTPBody = [self urlEncodeParams:[user jsonRepresentation]];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLUser class]
                                                                                 successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)deleteUser:(GLUser *)user
                           success:(GLGitlabSuccessBlock)successBlock
                           failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kSingleUserEndpoint, user.userId]
                                                     method:GLNetworkOperationDeleteMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *responseObject) {
        successBlock(nil);
    };
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeVoid
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)updateReceivingInfo:(ino64_t)userID
                               privateToken:(NSString *)privateToken
                                       name:(NSString *)name
                                phoneNumber:(NSString *)phoneNumber
                                    address:(NSString *)address
                                  extraInfo:(NSString *)extraInfo
                                    success:(GLGitlabSuccessBlock)successBlock
                                    failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kReceivingInfoEndpoint, userID]
                                                     params:@{
                                                              kPrivateToken: privateToken,
                                                              kName: name,
                                                              kPhoneNumber: phoneNumber,
                                                              kAddress: address,
                                                              kExtraInfo: extraInfo
                                                              }
                                                     method:GLNetworkOperationPostMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *responseObject) {
        successBlock(nil);
    };

    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)fetchReceivingInfo:(int64_t)userID
                              privateToken:(NSString *)privateToken
                                   success:(GLGitlabSuccessBlock)successBlock
                                   failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kReceivingInfoEndpoint, userID]
                                                     params:@{kPrivateToken: privateToken}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *responseObject) {
        successBlock(responseObject);
    };
    
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}



@end
