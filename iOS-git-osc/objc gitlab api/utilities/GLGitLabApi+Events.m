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
static NSString * const kUserEventsEndPoint = @"events/user/%lld";
static NSString * const kKeyPrivateToken = @"private_token";
static NSString * const kKeyPage = @"page";

@implementation GLGitlabApi (Events)

- (GLNetworkOperation *)getEventsWithPrivateToken:(NSString *)privateToken
                                             page:(NSInteger)page
                                          success:(GLGitlabSuccessBlock)successBlock
                                          failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kEventsEndPoint
                                                     params:@{kKeyPrivateToken:privateToken, kKeyPage:@(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLEvent class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getUserEvents:(int64_t)userId
                                 page:(NSInteger)page
                              success:(GLGitlabSuccessBlock)successBlock
                              failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kUserEventsEndPoint, userId]
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