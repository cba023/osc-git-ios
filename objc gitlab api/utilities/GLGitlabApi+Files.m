//
//  GLGitlabApi+Files.m
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 2/13/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLGitlabApi+Files.h"
#import "GLGitlabApi+Private.h"
#import "GLFile.h"
#import "GLBlob.h"

// Endpoint
static NSString * const kTreeEndpoint = @"/projects/%llu/repository/tree";
static NSString * const kBlobEndpoint = @"/projects/%llu/repository/files";

// Param keys
static NSString * const kPath = @"path";
static NSString * const kRefName = @"ref_name";
static NSString * const kFilePath = @"file_path";
static NSString * const kRef = @"ref";
static NSString * const kPrivateToken = @"private_token";

@implementation GLGitlabApi (Files)

- (GLNetworkOperation *)getRepositoryTreeForProjectId:(int64_t)projectId
                                         privateToken:(NSString *)privateToken
                                                 path:(NSString *)path
                                           branchName:(NSString *)branch
                                         successBlock:(GLGitlabSuccessBlock)success
                                         failureBlock:(GLGitlabFailureBlock)failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];;
    if (path || branch) {
        if (path) {
            params[kPath] = path;
        }
        
        if (branch) {
            params[kRefName] = branch;
        }
    }
    params[kPrivateToken] = privateToken;
    
    NSString *endpoint =  [NSString stringWithFormat:kTreeEndpoint, projectId];
    NSMutableURLRequest *request = [self requestForEndPoint:endpoint params:params method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self multipleObjectSuccessBlockForClass:[GLFile class] successBlock:success];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failure];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}

- (GLNetworkOperation *)getFileContentFromProject:(int64_t)projectId
                                     privateToken:(NSString *)privateToken
                                             path:(NSString *)path
                                       branchName:(NSString *)branch
                                     successBlock:(GLGitlabSuccessBlock)success
                                     failureBlock:(GLGitlabFailureBlock)failure;
{
    NSDictionary *parameters = @{kPrivateToken: privateToken, kRef: branch, kFilePath: path};
    NSMutableURLRequest *request = [self requestForEndPoint:[NSString stringWithFormat:kBlobEndpoint, projectId]
                                                     params:parameters
                                                     method:GLNetworkOperationGetMethod];
    
    GLNetworkOperationSuccessBlock localSuccessBlock = [self singleObjectSuccessBlockForClass:[GLBlob class] successBlock:success];
    GLNetworkOperationFailureBlock localFailureBlock = [self defaultFailureBlock:failure];
    
    return [self queueOperationWithRequest:request
                                      type:GLNetworkOperationTypeJson
                                   success:localSuccessBlock
                                   failure:localFailureBlock];
}
@end
