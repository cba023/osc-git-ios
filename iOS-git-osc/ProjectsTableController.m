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

@property NSInteger projectsType;
@property NSUInteger pageSize;
@property BOOL isFinishedLoad;
@property BOOL isLoading;
@property BOOL isFirstRequest;
@property LastCell *lastCell;

@end

@implementation ProjectsTableController

@synthesize projects;

static NSString * const cellId = @"ProjectCell";

- (id)initWithProjectsType:(NSInteger)projectsType
{
    self = [super init];
    if (self) {
        _projectsType = projectsType;
        _pageSize = projectsType < 7? 20: 15;
    }
    
    return self;
}

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
    self.navigationController.navigationBar.translucent = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ProjectCell class] forCellReuseIdentifier:cellId];
    self.tableView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    projects = [NSMutableArray new];
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
    
    //if (_projectsType != 7) {
        
    //}
    
    _isFirstRequest = YES;
    
    if ([Tools isPageCacheExist:_projectsType]) {
        [self loadFromCache];
        return;
    }
    
    if (_projectsType < 7) {
        [_lastCell loading];
        [self loadMore];
    }
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
    if (indexPath.row < projects.count) {
        GLProject *project = [projects objectAtIndex:indexPath.row];
        UILabel *descriptionLabel = [UILabel new];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        descriptionLabel.numberOfLines = 4;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.font = [UIFont systemFontOfSize:14];
        descriptionLabel.text = project.projectDescription.length > 0? project.projectDescription: @"暂无项目介绍";
        
        CGSize size = [descriptionLabel sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        CGFloat height = size.height;
        
        return height + 64;
    } else {
        return 60;
    }
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

#pragma mark - 从缓存加载

- (void)loadFromCache
{
    [projects removeAllObjects];
    _isFinishedLoad = NO;
    
    [projects addObjectsFromArray:[Tools getPageCache:_projectsType]];
    _isFinishedLoad = projects.count < _pageSize;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
    });
}


#pragma mark - 刷新

- (void)refresh
{
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadProjectsOnPage:1 refresh:YES];
            refreshInProgress = NO;
        });
    }
}

- (void)reload
{
    [projects removeAllObjects];
    _isFinishedLoad = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
    [self loadMore];
}

- (void)reloadType:(NSInteger)NewProjectsType
{
    _projectsType = NewProjectsType;
    _isFirstRequest = YES;
    
    if ([Tools isPageCacheExist:NewProjectsType]) {
        [self loadFromCache];
    } else {
        [self reload];
    }
}

- (void)loadMore
{
    if (_isFinishedLoad || _isLoading) {return;}
    
    _isLoading = YES;
    [_lastCell loading];
    [self loadProjectsOnPage:projects.count/_pageSize + 1 refresh:NO];
}


- (void)loadProjectsOnPage:(NSUInteger)page refresh:(BOOL)refresh
{
    if (![Tools isNetworkExist]) {
        if (refresh) {
            [self.refreshControl endRefreshing];
        } else {
            [_lastCell empty];
        }
        [Tools toastNotification:@"错误 无网络连接" inView:self.view];
        return;
    }
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            [Tools toastNotification:@"网络错误" inView:self.view];
        } else {
            _isFinishedLoad = [(NSArray *)responseObject count] < _pageSize;
            if (refresh) {
                [self.refreshControl endRefreshing];
                [projects removeAllObjects];
            }
            [projects addObjectsFromArray:responseObject];
            
            if (refresh || _isFirstRequest) {
                [Tools savePageCache:projects type:_projectsType];
                _isFirstRequest = NO;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
            });
        }
        _isLoading = NO;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (refresh) {
            [self.refreshControl endRefreshing];
        }
        
        if (_isFinishedLoad) {
            [_lastCell finishedLoad];
        } else {
            [_lastCell normal];
        }
        
        _isLoading = NO;
    };

    
    if (_projectsType < 3) {
        [[GLGitlabApi sharedInstance] getExtraProjectsType:_projectsType page:page success:success failure:failure];
    } else if (_projectsType == 3) {
        NSString *privateToken = [Tools getPrivateToken];
        [[GLGitlabApi sharedInstance] getUsersProjectsWithPrivateToken:privateToken onPage:page success:success failure:failure];
    } else if (_projectsType == 4) {
        [[GLGitlabApi sharedInstance] getStarredProjectsForUser:_userID success:success failure:failure];
    } else if (_projectsType == 5) {
        [[GLGitlabApi sharedInstance] getWatchedProjectsForUser:_userID success:success failure:failure];
    } else if (_projectsType == 6) {
        [[GLGitlabApi sharedInstance] getProjectsForLanguage:_languageID page:page success:success failure:failure];
    } else {
        [[GLGitlabApi sharedInstance] searchProjectsByQuery:_query page:page success:success failure:failure];
    }
}


@end
