//
//  ProjectsTableController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectsTableController.h"
#import "ProjectCell.h"
#import "FilesTableController.h"
#import "NavigationController.h"
#import "ProjectDetailsView.h"
#import "GLGitlab.h"
#import "Project.h"
#import "Tools.h"
#import "LastCell.h"

@interface ProjectsTableController ()

@property BOOL isFinishedLoad;
@property BOOL isLoading;
@property LastCell *lastCell;

@end

@implementation ProjectsTableController
@synthesize projects;

static NSString * const cellId = @"ProjectCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:(NavigationController *)self.navigationController
                                                                                action:@selector(showMenu)];
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ProjectCell class] forCellReuseIdentifier:cellId];
    self.tableView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    //self.refreshControl = [UIRefreshControl new];
    //[self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    //[self.tableView addSubview:self.refreshControl];
    
    self.projects = [NSMutableArray new];
    _lastCell = [[LastCell alloc] initCell];
    _isFinishedLoad = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self loadMore];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}


#pragma mark - 表格显示及操作

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < projects.count) {
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        GLProject *project = [self.projects objectAtIndex:indexPath.row];
        
        [Tools setPortraitForUser:project.owner view:cell.portrait cornerRadius:5.0];
        cell.projectNameField.text = [NSString stringWithFormat:@"%@ / %@", project.owner.name, project.name];
        cell.projectDescriptionField.text = project.projectDescription.length > 0? project.projectDescription: @"暂无项目介绍";
        cell.languageField.text = project.language? project.language: @"Unknown";
        cell.forksCount.text = [NSString stringWithFormat:@"%i", project.forksCount];
        cell.starsCount.text = [NSString stringWithFormat:@"%i", project.starsCount];
        
        return cell;
    } else {
        return _lastCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (_isFinishedLoad && projects.count == 0) {
        return;
    }
    if (row < self.projects.count) {
        GLProject *project = [projects objectAtIndex:row];
        if (project) {
            ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] init];
            projectDetails.project = project;
            if (_projectsType > 2) {
                [self.navigationController pushViewController:projectDetails animated:YES];
            } else {
                [self.parentViewController.navigationController pushViewController:projectDetails animated:YES];
            }
        }
    } else {
        if (!_isLoading) {
            [self loadMore];
        }
    }
}


#pragma mark - 基本数值设置

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projects.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - 上拉加载更多

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 下拉到最底部时显示更多数据
	if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
	{
        [self loadMore];
	}
}

- (void)loadMore
{
    if (_isFinishedLoad) {return;}

    [_lastCell loading];
    NSUInteger page = projects.count/20 + 1;
    //[self.projects addObjectsFromArray:[self loadProjectsPage:page]];
    [self loadProjectsPage:page];
    
#if 0
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (_isFinishedLoad) {
            [_lastCell finishedLoad];
        } else {
            [_lastCell normal];
        }
    });
#endif
}


#pragma mark - 刷新

#if 0
- (void)refresh
{
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *newProjects = [self loadProjectsPage:1];
            if (newProjects.count > 0) {
                [self.projects removeAllObjects];
                [self.projects addObjectsFromArray:newProjects];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
                refreshInProgress = NO;
            });
        });
    }
}
#endif

- (void)reloadType:(NSInteger)NewProjectsType
{
    _projectsType = NewProjectsType;
    _isFinishedLoad = NO;
    [self.projects removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    [self loadMore];
}


- (void)loadProjectsPage:(NSUInteger)page
{
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            if ([(NSArray *)responseObject count] < 20) {
                _isFinishedLoad = YES;
            }
            [projects addObjectsFromArray:responseObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (_isFinishedLoad) {
                    [_lastCell finishedLoad];
                } else {
                    [_lastCell normal];
                }
            });
        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
    };

    
    if (_projectsType < 3) {
        [[GLGitlabApi sharedInstance] getExtraProjectsType:_projectsType
                                                      page:page
                                                   success:success
                                                   failure:failure];
    } else if (_projectsType == 3) {
        NSString *privateToken = [Tools getPrivateToken];
        [[GLGitlabApi sharedInstance] getUsersProjectsWithPrivateToken:privateToken
                                                                onPage:page
                                                               success:success
                                                               failure:failure];
    } else if (_projectsType == 4) {
        [[GLGitlabApi sharedInstance] getStarredProjectsForUser:_userID
                                                        success:success
                                                        failure:failure];
    } else if (_projectsType == 5) {
        [[GLGitlabApi sharedInstance] getWatchedProjectsForUser:_userID
                                                        success:success
                                                        failure:failure];
    } else {
        [[GLGitlabApi sharedInstance] getProjectsForLanguage:_languageID
                                                        page:page
                                                     success:success
                                                     failure:failure];
    }
}

@end
