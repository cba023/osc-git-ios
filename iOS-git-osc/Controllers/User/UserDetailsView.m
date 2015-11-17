//
//  UserDetailsView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "UserDetailsView.h"
#import "EventsView.h"
#import "ProjectsTableController.h"
#import "PKRevealController.h"
#import "Tools.h"

@interface UserDetailsView ()

@property NSString *privateToken;
@property int64_t userID;

@property UISegmentedControl *segmentTitle;
@property EventsView *eventsView;
@property ProjectsTableController *ownProjects;
@property ProjectsTableController *starredProjects;
@property ProjectsTableController *watchedProjects;

@end

@implementation UserDetailsView

- (id)initWithPrivateToken:(NSString *)privateToken userID:(int64_t)userID
{
    self = [super init];
    if (self) {
        _privateToken = privateToken;
        _userID = userID;
        
        if (privateToken) {
            _eventsView = [[EventsView alloc] initWithPrivateToken:privateToken];
            _ownProjects = [[ProjectsTableController alloc] initWithPrivateToken:privateToken];
        } else {
            _eventsView = [[EventsView alloc] initWithUserID:userID];
            _ownProjects = [[ProjectsTableController alloc] initWithUserID:userID andProjectsType:8];
        }
        
        _starredProjects = [[ProjectsTableController alloc] initWithUserID:_userID andProjectsType:4];
        _watchedProjects = [[ProjectsTableController alloc] initWithUserID:_userID andProjectsType:5];
        
        [self addChildViewController:_eventsView];
        [self addChildViewController:_ownProjects];
        [self addChildViewController:_starredProjects];
        [self addChildViewController:_watchedProjects];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUInteger controllersInStack = self.navigationController.viewControllers.count;
    if (controllersInStack < 2) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(showMenu)];
    }
    
    self.navigationController.navigationBar.translucent = NO;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    _segmentTitle = [[UISegmentedControl alloc] initWithItems:@[@"动态", @"项目", @"Star", @"Watch"]];
    _segmentTitle.selectedSegmentIndex = 0;
    _segmentTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _segmentTitle.segmentedControlStyle = UISegmentedControlStyleBar;
#if 0
    _segmentTitle.layer.cornerRadius = 5.0;
    _segmentTitle.backgroundColor = [Tools uniformColor];
    _segmentTitle.tintColor = UIColorFromRGB(0xaf1219);
#endif
    _segmentTitle.frame = CGRectMake(0, 0, 210, 30);
    [_segmentTitle addTarget:self action:@selector(switchView) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentTitle;
    
    [self.view addSubview:_eventsView.view];
    _eventsView.view.frame = self.view.bounds;
    _eventsView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = YES;
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
            [self.view addSubview:_eventsView.view];
            _eventsView.view.frame = self.view.bounds;
            _eventsView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        case 1: {
            [self.view addSubview:_ownProjects.view];
            _ownProjects.view.frame = self.view.bounds;
            _ownProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        case 2: {
            [self.view addSubview:_starredProjects.view];
            _starredProjects.view.frame = self.view.bounds;
            _starredProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        case 3: {
            [self.view addSubview:_watchedProjects.view];
            _watchedProjects.view.frame = self.view.bounds;
            _watchedProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            break;
        }
        default:
            break;
    }
}




@end
