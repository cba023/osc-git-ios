//
//  ProjectDetailsView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLProject;

@interface ProjectDetailsView : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property GLProject *project;
@property GLProject *parentProject;

@property UIImageView *portrait;
@property UILabel *projectName;
@property UILabel *timeInterval;

@property UILabel *language;
@property UIButton *starButton;
@property UIButton *forkButton;

@property UITableView *projectInfo;

- (id)initWithProject:(GLProject *)project;
- (id)initWithProjectId:(int64_t)projectId;

@end
