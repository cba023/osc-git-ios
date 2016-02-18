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
#import "AFHTTPRequestOperationManager+Util.h"
#import "GITAPI.h"
#import "CacheProjectsUtil.h"
#import "TitleScrollViewController.h"
#import "EventsView.h"

#import "MJRefresh.h"
#import "DataSetObject.h"
#import "Reachability.h"

@interface ProjectsTableController ()

@property (nonatomic, copy) NSString *privateToken;
@property (nonatomic, assign) int64_t userID;
@property (nonatomic, assign) ProjectsType projectsType;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) DataSetObject *emptyDataSet;

@end

@implementation ProjectsTableController

static NSString * const cellId = @"ProjectCell";

- (id)initWithProjectsType:(ProjectsType)projectsType
{
    self = [super init];
    if (self) {
        _projectsType = projectsType;
    }
    
    return self;

}

- (id)initWithUserID:(int64_t)userID andProjectsType:(ProjectsType)projectsType
{
    self = [self initWithProjectsType:projectsType];
    _userID = userID;
    
    return self;
}

- (id)initWithPrivateToken:(NSString *)privateToken
{
    self = [self initWithProjectsType:ProjectsTypeUserProjects];
    _privateToken = privateToken;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    _page = 1;
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchProject:YES];
    }];
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchProject:NO];
    }];
    [(MJRefreshAutoNormalFooter *)self.tableView.mj_footer setTitle:@"已全部加载完毕" forState:MJRefreshStateNoMoreData];
    // 默认先隐藏footer
    self.tableView.mj_footer.hidden = YES;
    
    if (![Tools isConnectionAcailable]) {
        _projects = (NSMutableArray *)[[CacheProjectsUtil shareInstance] readProjectListWithProjectType:_projectsType];
        if (!_projects || _projects.count < 1) {
            _projects = [NSMutableArray new];
            [self fetchProject:YES];
        } else {
            [self.tableView reloadData];
        }
    } else {
        _projects = [NSMutableArray new];
        [self fetchProject:YES];
    }
    
    /* 设置空页面状态 */
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    self.emptyDataSet.state = emptyViewState;
    __weak ProjectsTableController *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchProject:YES];
    };
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 获取数据

- (NSString *)stringUrl
{
    NSMutableString *strUrl = [[NSMutableString alloc] initWithFormat:@"%@", GITAPI_HTTPS_PREFIX];
    
    switch (_projectsType) {
        case ProjectsTypeFeatured://0
        case ProjectsTypePopular://1
        case ProjectsTypeLatest://2
        {
            NSString *string = @[@"featured", @"popular", @"latest"][_projectsType];
            [strUrl appendFormat:@"%@/%@?",
            GITAPI_PROJECTS,
            string];
            
            break;
        }
        case ProjectsTypeStared://4
        case ProjectsTypeWatched://5
        {
            NSString *string = @[@"stared_projects", @"watched_projects"][_projectsType-4];
            [strUrl appendFormat:@"%@/%lld/%@?",
             GITAPI_USER,
             _userID,
             string];
            
            break;
        }
        case ProjectsTypeUserProjects://8
        {
            if (_privateToken.length) {
                [strUrl appendFormat:@"%@?private_token=%@&",
                 GITAPI_PROJECTS,
                 _privateToken];
            } else {
                [strUrl appendFormat:@"%@/%lld/%@?",
                 GITAPI_USER,
                 _userID,
                 GITAPI_PROJECTS];
            }
            
            break;
        }
        case ProjectsTypeLanguage://6
        {
            [strUrl appendFormat:@"%@/languages/%ld?",
                      GITAPI_PROJECTS,
                      (long)_languageID];
            break;
        }
        case ProjectsTypeSearch://7
        {
           [strUrl appendFormat:@"%@/search/%@?private_token=%@&",
                      GITAPI_PROJECTS,
                      _query,
                      _privateToken];
            [self.tableView reloadData];
            break;
        }
        case ProjectsTypeEventForUser://3
        {
            [strUrl appendFormat:@"%@/%@/%lld?",
                    GITAPI_EVENTS,
                    GITAPI_USER,
                    _userID];
            break;
        }

    }
    [strUrl appendFormat:@"page=%ld", (long)_page];
    
    return strUrl;
}

- (void)fetchProject:(BOOL)refresh
{
    self.emptyDataSet.state = emptyViewState;
    
    if (refresh) {
        _page = 1;
    } else {
        _page++;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSString *strUrl = [[self stringUrl] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (refresh) {
                 [_projects removeAllObjects];
             }
             
             if ([responseObject count] == 0) { } else {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLProject *project = [[GLProject alloc] initWithJSON:obj];
                     [_projects addObject:project];
                 }];
                 
                 if (refresh) {
                     [[CacheProjectsUtil shareInstance] insertProjectList:_projects andProjectType:_projectsType];
                 }
                 
             }
             
             if (_projects.count < 20) {
                 [self.tableView.mj_footer endRefreshingWithNoMoreData];
             } else {
                 [self.tableView.mj_footer endRefreshing];
             }
             
             if (_projects.count == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有相关项目";
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
                 [self.tableView.mj_header endRefreshing];
             });
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.emptyDataSet.state = netWorkingErrorState;
                 [self.tableView reloadData];
                 [self.tableView.mj_header endRefreshing];
                 [self.tableView.mj_footer endRefreshing];
             });
         }];
    
}

#pragma mark - 表格显示及操作

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _projects.count) {
        ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        GLProject *project = [self.projects objectAtIndex:indexPath.row];
        [cell contentForProjects:project];
        
        cell.portrait.tag = indexPath.row;
        cell.portrait.userInteractionEnabled = YES;
        [cell.portrait addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickUserProtrait:)]];
        
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.projects.count) {
        GLProject *project = [_projects objectAtIndex:row];
        
        if (project) {
            ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectID:project.projectId projectNameSpace:project.nameSpace];
            [projectDetails setHidesBottomBarWhenPushed:YES];
            
            if (_projectsType > 2) {

                [self.navigationController pushViewController:projectDetails animated:YES];
            } else {
                
                [self.parentViewController.navigationController pushViewController:projectDetails animated:YES];
            }
        }

    }
}

#pragma mark - 点击头像
- (void)clickUserProtrait:(UITapGestureRecognizer *)recognizer
{
    GLProject *project = [_projects objectAtIndex:recognizer.view.tag];
    
    TitleScrollViewController *ownDetailsView = [[TitleScrollViewController alloc] initWithTitle:project.owner.name
                                                                                    andSubTitles:@[@"动态", @"项目", @"Star", @"Watch"]
                                                                               andSubControllers:@[
                                                                                                   [[EventsView alloc] initWithUserID:project.owner.userId],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:project.owner.userId andProjectsType:ProjectsTypeUserProjects],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:project.owner.userId andProjectsType:ProjectsTypeStared],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:project.owner.userId andProjectsType:ProjectsTypeWatched]
                                                                                                   ]
                                                                                  andUnderTabbar:NO
                                                                                 andUserPortrait:NO];
    ownDetailsView.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:ownDetailsView animated:YES];
}

#pragma mark - 基本数值设置

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _projects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _projects.count) {
        GLProject *project = [_projects objectAtIndex:indexPath.row];
        UILabel *descriptionLabel = [UILabel new];
        descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
        descriptionLabel.numberOfLines = 4;
        descriptionLabel.textAlignment = NSTextAlignmentLeft;
        descriptionLabel.font = [UIFont systemFontOfSize:14];
        descriptionLabel.text = project.projectDescription.length > 0? project.projectDescription: @"暂无项目介绍";
        
        CGFloat height = [descriptionLabel sizeThatFits:CGSizeMake(tableView.frame.size.width - 57, MAXFLOAT)].height;
        
        return height + 64;
    } else {
        return 60;
    }
}

#pragma mark - 设置分割线对齐
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


@end
