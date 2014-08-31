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
@property int64_t userID;
@property NSInteger languageID;
@property NSString *query;

- (id)initWithProjectsType:(NSInteger)projectsType;
- (void)reloadType:(NSInteger)newArrangeType;
- (void)reload;

@end
