//
//  ProjectsViewController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectsViewController.h"
#import "NavigationController.h"

@interface ProjectsViewController ()

@end

@implementation ProjectsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.segmentTitle = [[UISegmentedControl alloc] initWithItems:@[@"推荐", @"热门", @"最近更新"]];
        self.segmentTitle.selectedSegmentIndex = 0;
        self.segmentTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.segmentTitle.segmentedControlStyle = UISegmentedControlStyleBar;
        self.segmentTitle.frame = CGRectMake(0, 0, 200, 30);
        [self.segmentTitle addTarget:self action:@selector(switchView) forControlEvents:UIControlEventValueChanged];
        self.navigationItem.titleView = self.segmentTitle;
        
        self.projectsTable = [[ProjectsTableController alloc] init];
        self.projectsTable.personal = NO;
        self.projectsTable.arrangeType = 0;
        [self addChildViewController:self.projectsTable];
        [self.view addSubview:self.projectsTable.view];
        self.projectsTable.view.frame = self.view.bounds;
        self.projectsTable.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(NavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchView
{
    [self.projectsTable reloadType:self.segmentTitle.selectedSegmentIndex];
}

@end
