//
//  GLGitLabApi(Events).m
//  testAPI
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLEvent.h"
#import "GLGitLabApi+Events.h"
#import "GLGitlabApi+Private.h"

static NSString * const kEventsEndPoint = @"/events";
static NSString * const kKeyPrivateToken = @"private_token";
static NSString * const kKeyPage = @"page";

@implementation GLGitlabApi (Events)

- (GLNetworkOperation *)getEventsWithPrivateToken:(NSString *)private_token
                                             page:(int)page
                                          success:(GLGitlabSuccessBlock)successBlock
                                          failure:(GLGitlabFailureBlock)failureBlock
{
    NSDictionary *parameters = @{kKeyPrivateToken: private_token, kKeyPage: @(page)};
    NSMutableURLRequest *request = [self requestForEndPoint:kEventsEndPoint
                                                     params:parameters
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLEvent class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getUserEvents:(int64_t)userId
                                 page:(int)page
                              success:(GLGitlabSuccessBlock)successBlock
                              failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:@"%@/user/%lld", kEventsEndPoint, userId]
                                                     params:@{kKeyPage: @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLEvent class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}


@end