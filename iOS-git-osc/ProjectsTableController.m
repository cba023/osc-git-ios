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
#import "ProjectDetailsView.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "LastCell.h"
#import "PKRevealController.h"

@interface ProjectsTableController ()

@property NSString *privateToken;
@property int64_t userID;
@property NSUInteger projectsType;
@property NSUInteger pageSize;

@property BOOL isFinishedLoad;
@property BOOL isLoading;
@property BOOL isFirstRequest;
@property LastCell *lastCell;

@end

@implementation ProjectsTableController

@synthesize projects;

static NSString * const cellId = @"ProjectCell";

- (id)initWithProjectsType:(NSUInteger)projectsType
{
    self = [super init];
    if (self) {
        _projectsType = projectsType;
        _pageSize = projectsType != 7? 20: 15;
    }
    
    return self;

}

- (id)initWithUserID:(int64_t)userID andProjectsType:(NSUInteger)projectsType
{
    self = [self initWithProjectsType:projectsType];
    _userID = userID;
    
    return self;
}

- (id)initWithPrivateToken:(NSString *)privateToken
{
    self = [self initWithProjectsType:3];
    _privateToken = privateToken;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.navigationController.viewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(showMenu)];
    }
#if 1
    self.navigationController.navigationBar.translucent = NO;
#else
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
    {
        self.parentViewController.edgesForExtendedLayout = UIRectEdgeNone;
        self.parentViewController.automaticallyAdjustsScrollViewInsets = YES;
    }
#endif
    
    [self.tableView registerClass:[ProjectCell class] forCellReuseIdentifier:cellId];
    self.tableView.backgroundColor = [Tools uniformColor];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    projects = [NSMutableArray new];
    _lastCell = [[LastCell alloc] initCell];
    _isFinishedLoad = NO;
}

- (void)showMenu
{
    [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (projects.count > 0 || _isFinishedLoad) {
        return;
    }
    
    if ([self needCache] && [Tools isPageCacheExist:_projectsType]) {
        [_lastCell loading];
        [self loadFromCache];
        return;
    }
    
    _isFirstRequest = YES;
    if (_projectsType != 7) {
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
    
    if (row < self.projects.count) {
        GLProject *project = [projects objectAtIndex:row];        
        
        if (project) {
            ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectID:project.projectId];
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
        
        return size.height + 64;
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

- (void)loadMore
{
    if (_isFinishedLoad || _isLoading) {return;}
    
    _isLoading = YES;
    [_lastCell loading];
    [self loadProjectsOnPage:(projects.count + _pageSize - 1)/_pageSize + 1 refresh:NO];
}


- (void)loadProjectsOnPage:(NSUInteger)page refresh:(BOOL)refresh
{
    if (![Tools isNetworkExist]) {
        if (refresh) {
            [self.refreshControl endRefreshing];
        } else {
            _isLoading = NO;
            if (_isFinishedLoad) {
                [_lastCell finishedLoad];
            } else {
                [_lastCell normal];
            }
        }
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.parentViewController.view];
        return;
    }
    
    GLGitlabSuccessBlock success = [self successBlockIfRefresh:refresh];
    GLGitlabFailureBlock failure = [self failureBlockIfrefresh:refresh];
    
    if (_projectsType < 3) {
        [[GLGitlabApi sharedInstance] getExtraProjectsType:_projectsType page:page success:success failure:failure];
    } else if (_projectsType == 3) {
        [[GLGitlabApi sharedInstance] getUsersProjectsWithPrivateToken:_privateToken onPage:page success:success failure:failure];
    } else if (_projectsType == 4) {
        [[GLGitlabApi sharedInstance] getStarredProjectsForUser:_userID page:page success:success failure:failure];
    } else if (_projectsType == 5) {
        [[GLGitlabApi sharedInstance] getWatchedProjectsForUser:_userID page:page success:success failure:failure];
    } else if (_projectsType == 6) {
        [[GLGitlabApi sharedInstance] getProjectsForLanguage:_languageID page:page success:success failure:failure];
    } else if (_projectsType == 7) {
        [[GLGitlabApi sharedInstance] searchProjectsByQuery:_query page:page success:success failure:failure];
    } else {
        [[GLGitlabApi sharedInstance] projectsOfUser:_userID page:page success:success failure:failure];
    }
}

- (GLGitlabSuccessBlock)successBlockIfRefresh:(BOOL)refresh
{
    return
    
    ^(id responseObject) {
        if (refresh) {
            [self.refreshControl endRefreshing];
            [projects removeAllObjects];
        }
        
        if ([responseObject count] == 0) {
            _isFinishedLoad = YES;
            [_lastCell finishedLoad];
        } else {
            _isFinishedLoad = [(NSArray *)responseObject count] < _pageSize;
            
            for (GLProject *newProject in responseObject) {
                BOOL shouldBeAdded = YES;
                for (GLProject *project in projects) {
                    if (newProject.projectId == project.projectId) {
                        shouldBeAdded = NO;
                        break;
                    }
                }
                if (shouldBeAdded) {
                    [projects addObject:newProject];
                }
            }
            
            if ((refresh || _isFirstRequest) && [self needCache]) {
                [Tools savePageCache:responseObject type:_projectsType];
                _isFirstRequest = NO;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
            });
        }
        _isLoading = NO;
    };
}

- (GLGitlabFailureBlock)failureBlockIfrefresh:(BOOL)refresh
{
    return
    
    ^(NSError *error) {
        if (refresh) {
            [self.refreshControl endRefreshing];
        }
        
        if (error != nil) {
            [Tools toastNotification:[NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code] inView:self.view];
        } else {
            [Tools toastNotification:@"网络错误" inView:self.view];
        }
        
        if (_isFinishedLoad) {
            [_lastCell finishedLoad];
        } else {
            [_lastCell normal];
        }
        
        _isLoading = NO;
    };
}


- (BOOL)needCache
{
    if (_projectsType <= 3) {return YES;}
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    int64_t userID = [[user objectForKey:@"id"] longLongValue];
    
    if (_projectsType <= 5 && _userID == userID) {return YES;}
    
    return NO;
}


@end
