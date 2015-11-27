//
//  ProjectsMembersViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/27.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "ProjectsCommitsViewController.h"
#import "ProjectsCommitCell.h"
#import "UIView+Toast.h"
#import "Tools.h"
#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "GLCommit.h"
#import "LastCell.h"

@interface ProjectsCommitsViewController ()

@property int64_t projectID;
@property NSString *projectNameSpace;
@property NSMutableArray *commits;

@property BOOL isLoading;
@property BOOL isFinishedLoad;
@property LastCell *lastCell;

@end

@implementation ProjectsCommitsViewController

static NSString * const cellId = @"ProjectsCommitCell";

- (id)initWithProjectID:(int64_t)projectID  projectNameSpace:(NSString *)nameSpace
{
    self = [super init];
    if (self) {
        _projectID = projectID;
        _projectNameSpace = nameSpace;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_commits.count > 0 || _isFinishedLoad) {return;}
    
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height)
                            animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.title = @"提交";
    _commits = [NSMutableArray new];
    
    [self.tableView registerClass:[ProjectsCommitCell class] forCellReuseIdentifier:cellId];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    _lastCell = [[LastCell alloc] initCell];
    
    [self fetchForCommitDataOnPage:1 refresh:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchForCommitDataOnPage:(NSInteger)page refresh:(BOOL)refresh
{
    if (![Tools isNetworkExist]) {
        if (refresh) {
            [self.refreshControl endRefreshing];
            _lastCell.status = LastCellStatusVisible;
        } else {
            _isLoading = NO;
            if (_isFinishedLoad) {
                [_lastCell finishedLoad];
            } else {
                [_lastCell normal];
            }
        }
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    }
    
    [self.view makeToastActivity];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [user objectForKey:@"private_token"];
    
    NSString *strUrl = privateToken.length ? [NSString stringWithFormat:@"%@%@/%@/repository/commits?private_token=%@&page=%lu", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, [Tools getPrivateToken], (unsigned long)page] : [NSString stringWithFormat:@"%@%@/%@/repository/commits?page=%lu", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, (unsigned long)page];

    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             [self.view hideToastActivity];
             
             if (refresh) {
                 [self.refreshControl endRefreshing];
                 [_commits removeAllObjects];
             }
             
             if ([responseObject count] == 0) {
                 _isFinishedLoad = YES;
                 [_lastCell finishedLoad];
             } else {
                 _isFinishedLoad = [(NSArray *)responseObject count] < 20;
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLCommit *commit = [[GLCommit alloc] initWithJSON:obj];
                     [_commits addObject:commit];
                 }];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                     if (refresh) {[self.refreshControl endRefreshing];}
                     _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
                 });
             }
             _isLoading = NO;
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             [self.view hideToastActivity];
             
             if (error != nil) {
                 [Tools toastNotification:[NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code] inView:self.view];
             } else {
                 [Tools toastNotification:@"网络错误" inView:self.view];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 _lastCell.status = LastCellStatusVisible;
                 [_lastCell errorStatus];
                 [self.tableView reloadData];
                 if (refresh) {
                     [self.refreshControl endRefreshing];
                 }
             });
             
             _isLoading = NO;
    }];
}

#pragma mark - 刷新

- (void)refresh
{
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fetchForCommitDataOnPage:1 refresh:YES];
            refreshInProgress = NO;
        });
    }
}

#pragma mark - 下拉操作

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 下拉到最底部时显示更多数据
    if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
    {
        [self loadMore];
    }
}

#pragma mark - 加载

- (void)loadMore
{
    if (_isFinishedLoad || _isLoading) {return;}
    
    _isLoading = YES;
    [_lastCell loading];
    [self fetchForCommitDataOnPage:_commits.count/20 + 2 refresh:NO];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_lastCell.status == LastCellStatusNotVisible) {return _commits.count;}
    return _commits.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _commits.count) {
        GLCommit *commit = _commits[indexPath.row];
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont boldSystemFontOfSize:14];
        label.text = commit.title;
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 68, MAXFLOAT)].height;
        
        return height + 69;
    } else {
        return 60;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _commits.count) {
        ProjectsCommitCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        GLCommit *commit = _commits[indexPath.row];
        [cell contentForProjectsCommit:commit];
        
        return cell;
    } else {
        return _lastCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
