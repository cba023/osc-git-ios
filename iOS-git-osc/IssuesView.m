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
#import "NavigationController.h"
#import "GLGitlab.h"
#import "NotesView.h"
#import "IssueCreation.h"
#import "Tools.h"
#import "LastCell.h"

@interface IssuesView ()

@property BOOL isLoading;
@property BOOL isFinishedLoad;
@property LastCell *lastCell;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"问题";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建Issue"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushIssueCreationView)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_lastCell loading];
    [self loadIssuesOnPage:1 refresh:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithProjectId:(int64_t)projectId
{
    self = [super init];
    if (self) {
        self.projectId = projectId;
    }
    
    return self;
}

#pragma mark - UITableviewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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

#pragma mark - UITableViewDelegate

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
            [self loadIssuesOnPage:1 refresh:YES];
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
    [self loadIssuesOnPage:issues.count/20 + 1 refresh:NO];
}

- (void)loadIssuesOnPage:(NSUInteger)page refresh:(BOOL)refresh
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
    
    GLGitlabSuccessBlock success = [self successBlockIfRefresh:refresh];
    GLGitlabFailureBlock failure = [self failureBlockIfrefresh:refresh];
    
    [[GLGitlabApi sharedInstance] getAllIssuesForProjectId:_projectId
                                              privateToken:_privateToken
                                                      page:page
                                          withSuccessBlock:success
                                           andFailureBlock:failure];
}

#pragma mark - issues request

- (GLGitlabSuccessBlock)successBlockIfRefresh:(BOOL)refresh {
    return
    
    ^(id responseObject) {
        if ([responseObject count] == 0) {
            [_lastCell finishedLoad];
        } else {
            if (refresh) {
                [self.refreshControl endRefreshing];
                [issues removeAllObjects];
            }
            
            _isFinishedLoad = [(NSArray *)responseObject count] < 20;
            
            NSUInteger repeatedCount = [Tools numberOfRepeatedIssueds:issues issue:[responseObject objectAtIndex:0]];
            NSUInteger length = [responseObject count] < 20 - repeatedCount? [responseObject count]: 20 - repeatedCount;
            [issues addObjectsFromArray:[responseObject subarrayWithRange:NSMakeRange(repeatedCount, length)]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
            });
        }
        _isLoading = NO;
    };
}


- (GLGitlabFailureBlock)failureBlockIfrefresh:(BOOL)refresh {
    return
    
    ^(NSError *error) {
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
}



@end
