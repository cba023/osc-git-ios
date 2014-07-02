//
//  ProjectsViewController.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectsTableController.h"

@interface ProjectsViewController : UIViewController

@property (strong, nonatomic) UISegmentedControl *segmentTitle;
@property (strong, nonatomic) ProjectsTableController *projectsTable;

- (void)switchView;

@end
