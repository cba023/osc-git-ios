//
//  IssuesView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssuesView.h"
#import "IssueCell.h"
#import "Issue.h"
#import "GLGitlab.h"
#import "NotesView.h"
#import "IssueCreation.h"
#import "Tools.h"
#import "LastCell.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"

@interface IssuesView ()

@property BOOL isLoading;
@property BOOL isFinishedLoad;
@property LastCell *lastCell;
@property NSString *projectNameSpace;
@property NSString *privateToken;

@end

static NSString * const cellId = @"IssueCell";

@implementation IssuesView

@synthesize issues;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithProjectId:(int64_t)projectId projectNameSpace:(NSString *)nameSpace
{
    self = [super init];
    if (self) {
        self.projectId = projectId;
        self.projectNameSpace = nameSpace;
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (issues.count > 0 || _isFinishedLoad) {return;}
    
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y-self.refreshControl.frame.size.height)
                            animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"问题";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建Issue"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushIssueCreationView)];

    [self.tableView registerClass:[IssueCell class] forCellReuseIdentifier:cellId];
    self.tableView.backgroundColor = [Tools uniformColor];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    issues = [NSMutableArray new];
    _privateToken = [Tools getPrivateToken];
    _lastCell = [[LastCell alloc] initCell];
    
    [self fetchIssuesOnPage:1 refresh:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview things

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_lastCell.status == LastCellStatusNotVisible) {return issues.count;}
    return issues.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < issues.count) {
        IssueCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        GLIssue *issue = [issues objectAtIndex:indexPath.row];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [Tools setPortraitForUser:issue.author view:cell.portrait cornerRadius:5.0];
        [cell.title setText:issue.title];
        [cell.issueInfo setAttributedText:[Issue generateIssueInfo:issue]];
        
        return cell;
    } else {
        return _lastCell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < issues.count) {
        GLIssue *issue = [issues objectAtIndex:indexPath.row];
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setFont:[UIFont systemFontOfSize:16]];
        [label setText:issue.title];
        
        CGFloat titleHeight = [label sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 85, MAXFLOAT)].height;
        
        return titleHeight + 41;
    } else {
        return 60;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row < issues.count) {
        GLIssue *issue = [issues objectAtIndex:indexPath.row];
        NotesView *notesView = [[NotesView alloc] init];
        notesView.issue = issue;
        notesView.title = [NSString stringWithFormat:@"#%lld", issue.issueIid];
        
        [self.navigationController pushViewController:notesView animated:YES];
    } else {
        [self loadMore];
    }
}

#pragma mark - pushIssueCreationView

- (void)pushIssueCreationView
{
    IssueCreation *issueCreationView = [IssueCreation new];
    issueCreationView.projectId = self.projectId;
    [self.navigationController pushViewController:issueCreationView animated:YES];
}

#pragma mark - 刷新

- (void)refresh
{
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self fetchIssuesOnPage:1 refresh:YES];
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
    [self fetchIssuesOnPage:issues.count/20 + 2 refresh:NO];
}

#pragma mark - 获取数据
- (void)fetchIssuesOnPage:(NSUInteger)page refresh:(BOOL)refresh
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
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/issues?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, [Tools getPrivateToken]];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if (refresh) {
                 [self.refreshControl endRefreshing];
                 [issues removeAllObjects];
             }
             
             if ([responseObject count] == 0) {
                 _isFinishedLoad = YES;
                 [_lastCell finishedLoad];
             } else {
                 _isFinishedLoad = [(NSArray *)responseObject count] < 20;
                 
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLIssue *issue = [[GLIssue alloc] initWithJSON:obj];
                     [issues addObject:issue];
                 }];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                     if (refresh) {[self.refreshControl endRefreshing];}
                     _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
                 });
             }
             _isLoading = NO;
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
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


@end
