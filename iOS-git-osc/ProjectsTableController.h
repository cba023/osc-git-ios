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
@property NSInteger projectsType;
@property int64_t userID;
@property NSInteger languageID;
@property NSString *query;

- (void)reloadType:(NSInteger)newArrangeType;
- (void)refresh;

@end
