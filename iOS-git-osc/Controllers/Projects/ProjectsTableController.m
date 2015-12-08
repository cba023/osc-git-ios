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
//#import "LastCell.h"
#import "PKRevealController.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "GITAPI.h"

#import "MJRefresh.h"
#import "DataSetObject.h"

@interface ProjectsTableController ()

@property NSString *privateToken;
@property int64_t userID;
@property NSUInteger projectsType;
//@property NSUInteger pageSize;

@property BOOL isFinishedLoad;
@property BOOL isLoading;
@property BOOL isFirstRequest;
//@property LastCell *lastCell;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic,strong) DataSetObject *emptyDataSet;

@end

@implementation ProjectsTableController

//@synthesize projects;

static NSString * const cellId = @"ProjectCell";

- (id)initWithProjectsType:(NSUInteger)projectsType
{
    self = [super init];
    if (self) {
        _projectsType = projectsType;
//        _pageSize = projectsType != 7? 20: 15;
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
    
    _projects = [NSMutableArray new];
//    _lastCell = [[LastCell alloc] initCell];
    _isFinishedLoad = NO;
    
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
    
    /* 设置空页面状态 */
    [self fetchProject:YES];
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    __weak ProjectsTableController *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchProject:YES];
    };
    self.tableView.tableFooterView = [UIView new];
    
    [self viewForWeatherCache];
    
    _isFirstRequest = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewForWeatherCache
{
    if (_projects.count > 0 || _isFinishedLoad) {
        return;
    }
    
    if ([self needCache] && [Tools isPageCacheExist:_projectsType]) {
        [self loadFromCache];
        return;
    }
}

#pragma mark - 获取数据

- (void)fetchProject:(BOOL)refresh
{
    self.emptyDataSet.state = loadingState;
    
    if (refresh) {
        _page = 1;
    } else {
        _page++;
    }
    
    NSString *strUrl;
    
    switch (_projectsType) {
        case 0:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/featured?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_PROJECTS,
                                                (long)_page];
            break;
        }
        case 1:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/popular?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_PROJECTS,
                                                (long)_page];
            break;
        }
        case 2:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/latest?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_PROJECTS,
                                                (long)_page];
            break;
        }
        case 3:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/%@/%lld?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_EVENTS,
                                                GITAPI_USER,
                                                _userID,
                                                (long)_page];
            break;
        }
        case 4:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/%lld/stared_projects?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_USER,
                                                _userID,
                                                (long)_page];
            break;
        }
        case 5:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/%lld/watched_projects?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_USER,
                                                _userID,
                                                (long)_page];
            break;
        }
        case 6:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/languages/%ld?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_PROJECTS,
                                                (long)_languageID,
                                                (long)_page];
            break;
        }
        case 7:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/search/%@?private_token=%@&page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_PROJECTS,
                                                _query,
                                                _privateToken,
                                                (long)_page];
            break;
        }
        case 8:
        {
            strUrl = [NSString stringWithFormat:@"%@/%@/%lld/projects?page=%ld",
                                                GITAPI_HTTPS_PREFIX,
                                                GITAPI_USER,
                                                _userID,
                                                (long)_page];
            break;
        }
        default:
            break;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (refresh) {
                 [_projects removeAllObjects];
             }
             
             if ([responseObject count] == 0) {
                 _isFinishedLoad = YES;
    
             } else {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLProject *project = [[GLProject alloc] initWithJSON:obj];
                     [_projects addObject:project];
                 }];
                 
//                 if ((refresh || _isFirstRequest) && [self needCache]) {
//                     [Tools savePageCache:responseObject type:_projectsType];
//                     _isFirstRequest = NO;
//                 }
                 
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
        
        [Tools setPortraitForUser:project.owner view:cell.portrait cornerRadius:5.0];
        cell.projectNameField.text = [NSString stringWithFormat:@"%@ / %@", project.owner.name, project.name];
        cell.projectDescriptionField.text = project.projectDescription.length > 0? project.projectDescription: @"暂无项目介绍";
        cell.languageField.text = project.language? project.language: @"Unknown";
        cell.forksCount.text = [NSString stringWithFormat:@"%i", project.forksCount];
        cell.starsCount.text = [NSString stringWithFormat:@"%i", project.starsCount];
        
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
        
        CGSize size = [descriptionLabel sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
        
        return size.height + 64;
    } else {
        return 60;
    }
}


#pragma mark - 从缓存加载

- (void)loadFromCache
{
    [_projects removeAllObjects];
    
    [_projects addObjectsFromArray:[Tools getPageCache:_projectsType]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
}

#pragma mark - 缓存

- (BOOL)needCache
{
    if (_projectsType <= 3) {return YES;}
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    int64_t userID = [[user objectForKey:@"id"] longLongValue];
    
    if (_projectsType <= 5 && _userID == userID) {return YES;}
    
    return NO;
}


@end
