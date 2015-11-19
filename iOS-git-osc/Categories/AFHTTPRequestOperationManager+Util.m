//
//  AFHTTPRequestOperationManager+Util.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/19.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "AFHTTPRequestOperationManager+Util.h"

@implementation AFHTTPRequestOperationManager (Util)

+ (instancetype)GitManager
{
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    [manager.requestSerializer setValue:[self generateUserAgent] forHTTPHeaderField:@"User-Agent"];
    
    return manager;
}

+ (NSString *)generateUserAgent
{
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *IDFV = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    return [NSString stringWithFormat:@"git.OSChina.NET/git_%@/%@/%@/%@/%@",
            appVersion,
            [UIDevice currentDevice].systemName,
            [UIDevice currentDevice].systemVersion,
            [UIDevice currentDevice].model,
            IDFV];
}


@end
