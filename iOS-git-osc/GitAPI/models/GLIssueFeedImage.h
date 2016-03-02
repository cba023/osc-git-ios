//
//  GLIssueFeedImage.h
//  Git@OSC
//
//  Created by 李萍 on 16/3/2.
//  Copyright © 2016年 chenhaoxiang. All rights reserved.
//

#import "GLBaseObject.h"

@interface GLIssueFeedImage : GLBaseObject

@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) NSDictionary *files;

@end
