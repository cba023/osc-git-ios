//
//  GLBlob.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLBaseObject.h"

@interface GLBlob : GLBaseObject

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) int64_t size;
@property (nonatomic, copy) NSString *encoding;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *ref;
@property (nonatomic, copy) NSString *blobId;
@property (nonatomic, copy) NSString *commitId;

//- (BOOL)isEqual:(id)other;

- (NSString *)description;

@end
