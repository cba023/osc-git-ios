//
//  GLGitlabApi+Projects.m
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/22/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLGitlabApi+Projects.h"
#import "GLGitlabApi+Private.h"
#import "GLProject.h"
#import "GLUser.h"
#import "GLEvent.h"
#import "GLBlob.h"
#import "GLLanguage.h"

static NSString * const kProjectEndpoint = @"/projects";
static NSString * const kProjectOwnedProjectsEndPoint = @"/projects/owned";
static NSString * const kProjectAllProjectsEndPoint = @"/projects/all";
static NSString * const kProjectSingleProjectEndPoint = @"/projects/%llu";
static NSString * const kProjectEndpointForUser = @"/projects/user/%llu";
static NSString * const kProjectEventsEndPoint = @"/projects/%llu/events";
static NSString * const kProjectUsersEndPoint = @"/projects/%llu/members";
static NSString * const kProjectReadmeEndPoint = @"/projects/%llu/readme";
static NSString * const kProjectPopularProjectsEndPoint = @"/projects/popular";
static NSString * const kProjectRecommendedProjectsEndPoint = @"/projects/featured";
static NSString * const kProjectLatestProjectsEndPoint = @"/projects/latest";
static NSString * const kProjectProjectsOfUser = @"/user/%llu/projects";
static NSString * const kProjectStarredProjectsEndPoint = @"/user/%llu/stared_projects";
static NSString * const kProjectWatchedProjectsEndPoint = @"/user/%llu/watched_projects";
static NSString * const kProjectSearchProjectsEndPoint = @"/projects/search/%@";
static NSString * const kProjectLanguagesEndPoint = @"/projects/languages";
static NSString * const kProjectLanguageProjectsEndPoint = @"/projects/languages/%ld";
static NSString * const kProjectStarAProjectEndPoint = @"/projects/%llu/star";
static NSString * const kProjectUnstarAProjectEndPoint = @"/projects/%llu/unstar";
static NSString * const kProjectWatchAProjectEndPoint = @"/projects/%llu/watch";
static NSString * const kProjectUnwatchAProjectEndPoint = @"/projects/%llu/unwatch";
static NSString * const kProjectRandomProjectEndPoint = @"/projects/random";
static NSString * const kProjectLuckMessage = @"/projects/luck_msg";

static NSString * const kKeyPrivate_token = @"private_token";
static NSString * const kKeyPage = @"page";

@implementation GLGitlabApi (Projects)
#pragma mark - Project Methods

- (GLNetworkOperation *)getUsersProjectsWithPrivateToken:(NSString *)privateToken
                                                  onPage:(NSUInteger)page
                                                 success:(GLGitlabSuccessBlock)successBlock
                                                 failure:(GLGitlabFailureBlock)failureBlock

{
    NSMutableURLRequest *request = [self requestForEndPoint:kProjectEndpoint
                                                     params:@{kKeyPrivate_token: privateToken,
                                                              kKeyPage: @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getUsersOwnedProjectsSuccess:(GLGitlabSuccessBlock)successBlock
                                             failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kProjectOwnedProjectsEndPoint
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getProjectWithId:(int64_t)projectId
                            privateToken:(NSString *)privateToken
                                 success:(GLGitlabSuccessBlock)successBlock
                                 failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectSingleProjectEndPoint, projectId]
                                                     params:@{kKeyPrivate_token: privateToken}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getProjectEventsForProject:(GLProject *)project
                                           success:(GLGitlabSuccessBlock)successBlock
                                           failure:(GLGitlabFailureBlock)failureBlock
{
    return [self getProjectEventsForProjectId:project.projectId
                                      success:successBlock
                                      failure:failureBlock];
}

- (GLNetworkOperation *)getProjectTeamUsers:(int64_t)projectId
                               privateToken:(NSString *)privateToken
                                    success:(GLGitlabSuccessBlock)successBlock
                                    failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectUsersEndPoint, projectId]
                                                     params:@{kKeyPrivate_token: privateToken}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localCussessBlock = [self multipleObjectSuccessBlockForClass:[GLUser class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localCussessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getProjectEventsForProjectId:(int64_t)projectId
                                             success:(GLGitlabSuccessBlock)successBlock
                                             failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectEventsEndPoint, projectId]
                                                     method:GLNetworkOperationGetMethod];
    request.HTTPMethod = GLNetworkOperationGetMethod;
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLEvent class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)createProjectNamed:(NSString *)projectName
                                   success:(GLGitlabSuccessBlock)successBlock
                                   failure:(GLGitlabFailureBlock)failureBlock
{
    GLProject *project = [GLProject new];
    project.name = projectName;
    
    return [self createProject:project
                       success:successBlock
                       failure:failureBlock];
}

- (GLNetworkOperation *)createProject:(GLProject *)project
                              success:(GLGitlabSuccessBlock)successBlock
                              failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kProjectEndpoint
                                                     method:GLNetworkOperationPostMethod];
    request.HTTPBody = [self urlEncodeParams:[project jsonCreateRepresentation]];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}


- (GLNetworkOperation *)createProjectNamed:(NSString *)projectName
                                   forUser:(GLUser *)user
                                   success:(GLGitlabSuccessBlock)successBlock
                                   failure:(GLGitlabFailureBlock)failureBlock
{
    GLProject *project = [GLProject new];
    project.name = projectName;
    
    return [self createProject:project
                       forUser:user
                       success:successBlock
                       failure:failureBlock];
}

- (GLNetworkOperation *)createProject:(GLProject *)project
                              forUser:(GLUser *)user
                              success:(GLGitlabSuccessBlock)successBlock
                              failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectEndpointForUser, user.userId]
                                                     method:GLNetworkOperationPostMethod];
    request.HTTPBody = [self urlEncodeParams:[project jsonCreateRepresentation]];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getExtraProjectsType:(NSInteger)type
                                        page:(NSUInteger)page
                                     success:(GLGitlabSuccessBlock)successBlock
                                     failure:(GLGitlabFailureBlock)failureBlock
{
    NSString *endPoint;
    switch (type) {
        case 0:
            endPoint = kProjectRecommendedProjectsEndPoint;break;
        case 1:
            endPoint = kProjectPopularProjectsEndPoint;break;
        default:
            endPoint = kProjectLatestProjectsEndPoint;break;
    }
    NSMutableURLRequest *request = [self requestForEndPoint:endPoint
                                                     params:@{@"page": @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)loadReadmeForProjectID:(int64_t)projectID
                                  privateToken:(NSString *)privateToken
                                       success:(GLGitlabSuccessBlock)successBlock
                                       failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectReadmeEndPoint, projectID]
                                                     params:@{kKeyPrivate_token: privateToken}
                                                     method:GLNetworkOperationGetMethod];

    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *resonseObject) {
        id object = [resonseObject objectForKey:@"content"];
        successBlock(object);
    };

    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}


- (GLNetworkOperation *)projectsOfUser:(int64_t)userID
                                  page:(NSUInteger)page
                               success:(GLGitlabSuccessBlock)successBlock
                               failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectProjectsOfUser, userID]
                                                     params:@{kKeyPage: @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}


- (GLNetworkOperation *)getStarredProjectsForUser:(int64_t)userID
                                             page:(NSUInteger)page
                                          success:(GLGitlabSuccessBlock)successBlock
                                          failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectStarredProjectsEndPoint, userID]
                                                     params:@{kKeyPage: @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}


- (GLNetworkOperation *)getWatchedProjectsForUser:(int64_t)userID
                                             page:(NSUInteger)page
                                          success:(GLGitlabSuccessBlock)successBlock
                                          failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectWatchedProjectsEndPoint, userID]
                                                     params:@{kKeyPage: @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
    
}


- (GLNetworkOperation *)searchProjectsByQuery:(NSString *)query
                                         page:(NSUInteger)page
                                      success:(GLGitlabSuccessBlock)successBlock
                                      failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectSearchProjectsEndPoint, query]
                                                     params:@{kKeyPage: @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getLanguagesListSuccess:(GLGitlabSuccessBlock)successBlock
                                       failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kProjectLanguagesEndPoint
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLLanguage class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getProjectsForLanguage:(NSInteger)languageID
                                          page:(NSUInteger)page
                                       success:(GLGitlabSuccessBlock)successBlock
                                       failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectLanguageProjectsEndPoint, (long)languageID]
                                                     params:@{kKeyPage: @(page)}
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)starProject:(int64_t)projectID
                       privateToken:(NSString *)privateToken
                            success:(GLGitlabSuccessBlock)successBlock
                            failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectStarAProjectEndPoint, projectID]
                                                     params:@{kKeyPrivate_token: privateToken}
                                                     method:GLNetworkOperationPostMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *resonseObject) {
        id object = [resonseObject objectForKey:@"count"];
        successBlock(object);
    };
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)watchProject:(int64_t)projectID
                        privateToken:(NSString *)privateToken
                             success:(GLGitlabSuccessBlock)successBlock
                             failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectWatchAProjectEndPoint, projectID]
                                                     params:@{kKeyPrivate_token: privateToken}
                                                     method:GLNetworkOperationPostMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *resonseObject) {
        id object = [resonseObject objectForKey:@"count"];
        successBlock(object);
    };
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)unstarProject:(int64_t)projectID
                         privateToken:(NSString *)privateToken
                              success:(GLGitlabSuccessBlock)successBlock
                              failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectUnstarAProjectEndPoint, projectID]
                                                     params:@{kKeyPrivate_token: privateToken}
                                                     method:GLNetworkOperationPostMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *resonseObject) {
        id object = [resonseObject objectForKey:@"count"];
        successBlock(object);
    };
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)unwatchProject:(int64_t)projectID
                          privateToken:(NSString *)privateToken
                               success:(GLGitlabSuccessBlock)successBlock
                               failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kProjectUnwatchAProjectEndPoint, projectID]
                                                     params:@{kKeyPrivate_token: privateToken}
                                                     method:GLNetworkOperationPostMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *resonseObject) {
        id object = [resonseObject objectForKey:@"count"];
        successBlock(object);
    };
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)fetchARandomProjectWithPrivateToken:(NSString *)privateToken
                                                    success:(GLGitlabSuccessBlock)successBlock
                                                    failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kProjectRandomProjectEndPoint
                                                     params:@{
                                                              kKeyPrivate_token: privateToken,
                                                              @"luck": @(1)
                                                              }
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLProject class] successBlock:successBlock];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)fetchLuckMessageSuccess:(GLGitlabSuccessBlock)successBlock
                                        failure:(GLGitlabFailureBlock)failureBlock
{
    NSMutableURLRequest *request = [self requestForEndPoint:kProjectLuckMessage
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = ^(NSDictionary *resonseObject) {
        id object = [resonseObject objectForKey:@"message"];
        successBlock(object);
    };

    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failureBlock];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}





@end
