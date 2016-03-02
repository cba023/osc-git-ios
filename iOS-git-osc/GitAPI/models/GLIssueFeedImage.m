//
//  GLIssueFeedImage.m
//  Git@OSC
//
//  Created by 李萍 on 16/3/2.
//  Copyright © 2016年 chenhaoxiang. All rights reserved.
//

#import "GLIssueFeedImage.h"

@implementation GLIssueFeedImage

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _isSuccess = [self checkForNull:json[@"success"]];
        _message = [self checkForNull:json[@"msg"]];
        _files = [self checkForNull:json[@"files"]][0];
    }
    return self;
}

@end
