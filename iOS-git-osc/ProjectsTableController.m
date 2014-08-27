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
#import "StatusCell.h"

@interface ProjectsTableController ()

@property BOOL isLoadOver;
@property BOOL isLoading;

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
    self.navigationController.navigationBar.translucent = NO;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.projects = [NSMutableArray new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self loadMore];
}


#pragma mark - 表格显示及操作

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (projects.count == 0) {
        NSInteger status = _isLoadOver? 3: 0;
        StatusCell *statusCell = [[StatusCell alloc] initWithStatus:status];
        return statusCell;
    }
    
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
        NSInteger status = _isLoading? 1: 2;
        StatusCell *statusCell = [[StatusCell alloc] initWithStatus:status];
        return statusCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (_isLoadOver && projects.count == 0) {
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
    if (_isLoadOver) {
        return projects.count == 0? 1: projects.count;
    }
    return self.projects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - 上拉加载更多

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_isLoadOver || _isLoading) {return;}
    
    // 下拉到最底部时显示更多数据
	if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
	{
        [self loadMore];
	}
}

- (void)loadMore
{
    if (_isLoadOver || _isLoading) {return;}
    _isLoading = YES;
    
    NSUInteger page = projects.count/20 + 1;
    [self.projects addObjectsFromArray:[self loadProjectsPage:page]];
    
    _isLoading = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - 刷新

- (void)refreshView:(UIRefreshControl *)refreshControl
{
    // http://stackoverflow.com/questions/19683892/pull-to-refresh-crashes-app helps a lot
    
    static BOOL refreshInProgress = NO;
    _isLoading = YES;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        [self.projects removeAllObjects];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.projects addObjectsFromArray:[self loadProjectsPage:1]];
            _isLoading = NO;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                
                refreshInProgress = NO;
            });
        });
    }
}

- (void)reloadType:(NSInteger)NewProjectsType
{
    _projectsType = NewProjectsType;
    [self.projects removeAllObjects];
    _isLoadOver = NO;
    
    [self.projects addObjectsFromArray:[Project loadExtraProjectType:_projectsType onPage:1]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


- (NSArray *)loadProjectsPage:(NSUInteger)page
{
    NSArray *newProjects;
    
    if (_projectsType < 3) {
        newProjects = [Project loadExtraProjectType:_projectsType onPage:page];
    } else if (_projectsType == 3) {
        newProjects = [Project getOwnProjectsOnPage:page];
    } else if (_projectsType == 4) {
        newProjects = [Project getStarredProjectsForUser:_userID];
    } else if (_projectsType == 5) {
        newProjects = [Project getWatchedProjectsForUser:_userID];
    } else {
        newProjects = [Project getProjectsForLanguage:_languageID page:page];
    }
    
    if (newProjects.count < 20) {
        _isLoadOver = YES;
    }
    
    return newProjects;
}

@end
