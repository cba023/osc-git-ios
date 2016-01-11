//
//  ProjectsTableController.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tools.h"

@interface ProjectsTableController : UITableViewController

@property (nonatomic, strong) NSMutableArray *projects;
@property NSInteger languageID;
@property NSString *query;

- (id)initWithProjectsType:(ProjectsType)projectsType;
- (id)initWithUserID:(int64_t)userID andProjectsType:(ProjectsType)projectsType;
- (id)initWithPrivateToken:(NSString *)privateToken;
- (void)fetchProject:(BOOL)refresh;

@end
