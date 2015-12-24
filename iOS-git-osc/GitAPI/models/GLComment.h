//
//  GLComment.h
//  Git@OSC
//
//  Created by 李萍 on 15/12/14.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "GLBaseObject.h"
#import "GLUser.h"

@interface GLComment : GLBaseObject

@property (nonatomic, assign) int64_t commentID;
@property (nonatomic, copy) NSString *creatTime;
@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *commitId;
@property (nonatomic, strong) GLUser *author;
@property (nonatomic, copy) NSString *noteString;

- (BOOL)isEqualToComment:(GLComment *)comment;

@end
