//
//  ProjectsViewController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectsViewController.h"
#import "PKRevealController.h"
#import "Tools.h"

@interface ProjectsViewController ()

@property UISegmentedControl *segmentTitle;
@property ProjectsTableController *recommendedProjects;
@property ProjectsTableController *hotProjects;
@property ProjectsTableController *recentUpdatedProjects;

@end

@implementation ProjectsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(showMenu)];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
    
    self.segmentTitle = [[UISegmentedControl alloc] initWithItems:@[@"推荐", @"热门", @"最近更新"]];
    self.segmentTitle.selectedSegmentIndex = 0;
    self.segmentTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.segmentTitle.segmentedControlStyle = UISegmentedControlStyleBar;
#if 0
    self.segmentTitle.layer.cornerRadius = 5.0;
    self.segmentTitle.backgroundColor = [Tools uniformColor];
    self.segmentTitle.tintColor = UIColorFromRGB(0xaf1219);
#endif
    self.segmentTitle.frame = CGRectMake(0, 0, 200, 30);
    [self.segmentTitle addTarget:self action:@selector(switchView) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segmentTitle;
    
    _recommendedProjects = [[ProjectsTableController alloc] initWithProjectsType:0];
    _hotProjects = [[ProjectsTableController alloc] initWithProjectsType:1];
    _recentUpdatedProjects = [[ProjectsTableController alloc] initWithProjectsType:2];
    
    [self addChildViewController:_recommendedProjects];
    [self addChildViewController:_hotProjects];
    [self addChildViewController:_recentUpdatedProjects];
    
    [self.view addSubview:_recommendedProjects.view];
    _recommendedProjects.view.frame = self.view.bounds;
    _recommendedProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)showMenu
{
    [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)switchView
{
    for (UIView *subview in [self.view subviews]) {
        [subview removeFromSuperview];
    }
    
    switch (_segmentTitle.selectedSegmentIndex) {
        case 0: {
            [self.view addSubview:_recommendedProjects.view];
            _recommendedProjects.view.frame = self.view.bounds;
            _recommendedProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        case 1: {
            [self.view addSubview:_hotProjects.view];
            _hotProjects.view.frame = self.view.bounds;
            _hotProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        case 2: {
            [self.view addSubview:_recentUpdatedProjects.view];
            _recentUpdatedProjects.view.frame = self.view.bounds;
            _recentUpdatedProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        default:
            break;
    }
}

@end
