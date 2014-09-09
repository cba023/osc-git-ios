//
//  File.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject

+ (BOOL)isCodeFile:(NSString *)fileName;
+ (BOOL)isImage:(NSString *)fileName;

@end
