//
//  ProjectsTableController.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectsTableController : UITableViewController <UIScrollViewDelegate>

@property NSMutableArray *projects;
@property NSInteger languageID;
@property NSString *query;

- (id)initWithProjectsType:(NSUInteger)projectsType;
- (id)initWithUserID:(int64_t)userID andProjectsType:(NSUInteger)projectsType;
- (id)initWithPrivateToken:(NSString *)privateToken;

- (void)reload;

@end
