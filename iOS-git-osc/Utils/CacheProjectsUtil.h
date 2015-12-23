//
//  CacheProjectsUtil.h
//  Git@OSC
//
//  Created by 李萍 on 15/12/21.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tools.h"
#import "GLProject.h"
#import "GLLanguage.h"

@interface CacheProjectsUtil : NSObject

//创建数据库
+ (instancetype)shareInstance;

//插入项目列表数据至数据表
- (void)insertProjectList:(NSArray *)projects andProjectType:(ProjectsType)projectType;
//读取项目列表数据
- (NSArray *)readProjectListWithProjectType:(ProjectsType)projectType;

//插入语言列表数据至数据表
- (void)insertLanguageList:(NSArray *)languages;
//读取语言列表数据
- (NSArray *)readLanguageList;

//清表
- (void)removeCache;

@end
