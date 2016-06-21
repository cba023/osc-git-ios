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
#import "UIView+Toast.h"
#import "TitleScrollViewController.h"
#import "EventsView.h"
#import "ProjectsTableController.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import "MJRefresh.h"
#import "DataSetObject.h"

@interface IssuesView ()

@property (nonatomic, assign) NSInteger page;
@property NSString *projectNameSpace;
@property NSString *privateToken;

@property (nonatomic,strong) DataSetObject *emptyDataSet;

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
    
    issues = [NSMutableArray new];
    _privateToken = [Tools getPrivateToken];
    _page = 1;
    
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchIssuesRefresh:YES];
    }];
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchIssuesRefresh:NO];
    }];
    [(MJRefreshAutoNormalFooter *)self.tableView.mj_footer setTitle:@"已全部加载完毕" forState:MJRefreshStateNoMoreData];
    // 默认先隐藏footer
    self.tableView.mj_footer.hidden = YES;
    
//    [self.tableView.mj_header beginRefreshing];
    /* 设置空页面状态 */
    [self fetchIssuesRefresh:YES];
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    self.emptyDataSet.state = emptyViewState;
    __weak IssuesView *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchIssuesRefresh:YES];
    };
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchIssuesRefresh:(BOOL)refresh
{
    self.emptyDataSet.state = emptyViewState;
    
    if (refresh) {
        _page = 1;
    } else {
        _page++;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectId];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/issues?private_token=%@&page=%lu", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, projectIdStr, [Tools getPrivateToken], (unsigned long)_page];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if (refresh) {
                 [issues removeAllObjects];
             }
             
             if ([responseObject count] > 0) {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLIssue *issue = [[GLIssue alloc] initWithJSON:obj];
                     [issues addObject:issue];
                 }];
             }
             
             if (issues.count < 20) {
                 [self.tableView.mj_footer endRefreshingWithNoMoreData];
             } else {
                 [self.tableView.mj_footer endRefreshing];
             }
             
             if (issues.count == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有相关Issue";
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


#pragma mark - tableview things

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return issues.count;
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
        
        UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(tapPortrait:)];
        cell.portrait.tag = indexPath.row;
        cell.portrait.userInteractionEnabled = YES;
        [cell.portrait addGestureRecognizer:tapPortraitRecognizer];
        
        return cell;
    } else {
        return [UITableViewCell new];
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
        notesView.projectNameSpace = _projectNameSpace;
        notesView.title = [NSString stringWithFormat:@"#%lld", issue.issueIid];
        
        [self.navigationController pushViewController:notesView animated:YES];
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

#pragma mark - recognizer头像
- (void)tapPortrait:(UITapGestureRecognizer *)sender
{
    GLIssue *issue = [issues objectAtIndex:((UIImageView *)sender.view).tag];
    
    TitleScrollViewController *ownDetailsView = [[TitleScrollViewController alloc] initWithTitle:issue.author.name
                                                                                    andSubTitles:@[@"动态", @"项目", @"Star", @"Watch"]
                                                                               andSubControllers:@[
                                                                                                   [[EventsView alloc] initWithUserID:issue.author.userId],                                                                                                   [[ProjectsTableController alloc] initWithUserID:issue.author.userId andProjectsType:ProjectsTypeUserProjects],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:issue.author.userId andProjectsType:ProjectsTypeStared],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:issue.author.userId andProjectsType:ProjectsTypeWatched]
                                                                                                   ]
                                                                                  andUnderTabbar:NO
                                                                                 andUserPortrait:NO];
    
    [self.navigationController pushViewController:ownDetailsView animated:YES];
}

#pragma mark - pushIssueCreationView

- (void)pushIssueCreationView
{
    IssueCreation *issueCreationView = [IssueCreation new];
    issueCreationView.projectId = self.projectId;
    issueCreationView.projectNameSpace = self.projectNameSpace;
    [self.navigationController pushViewController:issueCreationView animated:YES];
}


@end
