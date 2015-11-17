//
//  GLBlob.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLBlob.h"

static NSString * const kFileName = @"file_name";
static NSString * const kFIlePath = @"file_path";
static NSString * const kSize = @"size";
static NSString * const kEncoding = @"encoding";
static NSString * const kContent = @"content";
static NSString * const kRef = @"ref";
static NSString * const kBlobId = @"blob_id";
static NSString * const kCommitId = @"commit_id";

@implementation GLBlob

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if ((self = [super init])) {
        _fileName = [self checkForNull:json[kFileName]];
        _filePath = [self checkForNull:json[kFIlePath]];
        _size = [json[kSize] longLongValue];
        _encoding = [self checkForNull:json[kEncoding]];
        _content = [self checkForNull:json[kContent]];
        _ref = [self checkForNull:json[kRef]];
        _blobId = json[kBlobId];
        _commitId = json[kCommitId];
    }
    
    return self;
}

- (NSString *)description {
    return self.content;
}


@end
