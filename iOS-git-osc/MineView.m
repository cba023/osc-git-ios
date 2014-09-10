//
//  MineView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-10.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "MineView.h"
#import "EventsView.h"
#import "ProjectsTableController.h"
#import "NavigationController.h"

@interface MineView ()

@property NSString *privateToken;
@property int64_t userID;
@property BOOL isOwn;

@property UISegmentedControl *segmentTitle;
@property EventsView *eventsView;
@property ProjectsTableController *ownProjects;
@property ProjectsTableController *starredProjects;
@property ProjectsTableController *watchedProjects;

@end

@implementation MineView

- (id)initWithPrivateToken:(NSString *)privateToken userID:(int64_t)userID
{
    self = [super init];
    if (self) {
        _privateToken = privateToken;
        _userID = userID;
        
        if (privateToken.length > 0) {
            _isOwn = YES;
            _eventsView = [[EventsView alloc] initWithPrivateToken:privateToken];
        } else {
            _eventsView = [[EventsView alloc] initWithUserID:userID];
        }
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
    
    _segmentTitle = [[UISegmentedControl alloc] initWithItems:@[@"动态", @"项目", @"Star", @"Watch"]];
    _segmentTitle.selectedSegmentIndex = 0;
    _segmentTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _segmentTitle.segmentedControlStyle = UISegmentedControlStyleBar;
    _segmentTitle.frame = CGRectMake(0, 0, 210, 30);
    [_segmentTitle addTarget:self action:@selector(switchView) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = _segmentTitle;
    
    _ownProjects = [[ProjectsTableController alloc] initWithProjectsType:3];
    _starredProjects = [[ProjectsTableController alloc] initWithProjectsType:4];
    _watchedProjects = [[ProjectsTableController alloc] initWithProjectsType:5];
    
    [self addChildViewController:_eventsView];
    [self addChildViewController:_ownProjects];
    [self addChildViewController:_starredProjects];
    [self addChildViewController:_watchedProjects];
    
    [self.view addSubview:_eventsView.view];
    //[self.view addSubview:_ownProjects.view];
    //[self.view addSubview:_starredProjects.view];
    //[self.view addSubview:_watchedProjects.view];
    
    _eventsView.view.frame = self.view.bounds;
    _eventsView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
