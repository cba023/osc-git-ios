//
//  GLLanguage.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-22.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLBaseObject.h"

@class GLUser, GLBranch;

@interface GLLanguage : GLBaseObject

// id
@property (nonatomic, assign) NSInteger languageID;
// name
@property (nonatomic, copy) NSString *name;
// ident
@property (nonatomic, copy) NSString *ident;
// detail
@property (nonatomic, copy) NSString *detail;
// order
@property (nonatomic, assign) NSInteger order;
// parent_id
@property (nonatomic, assign) NSInteger parentID;
// project_count
@property (nonatomic, assign) NSInteger projectsCount;
// created_at
@property (nonatomic, copy) NSString *createdAt;
// updated_at
@property (nonatomic, copy) NSString *updatedAt;


@end

