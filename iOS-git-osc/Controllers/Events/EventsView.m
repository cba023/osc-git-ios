//
//  EventsView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLGitlab.h"
#import "EventsView.h"
#import "EventCell.h"
#import "Event.h"
#import "Tools.h"
#import "UIImageView+WebCache.h"
#import "ProjectDetailsView.h"
#import "TitleScrollViewController.h"
#import "ProjectsTableController.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "GITAPI.h"
#import "MJRefresh.h"
#import "DataSetObject.h"

static NSString * const kKeyPrivate_token = @"private_token";
static NSString * const EventCellIdentifier = @"EventCell";

@interface EventsView ()

@property (nonatomic, assign) int64_t userID;
@property (nonatomic, copy) NSString *privateToken;
@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, assign) BOOL isFinishedLoad;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isFirstRequest;

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, strong) DataSetObject *emptyDataSet;
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;

@end

@implementation EventsView

- (id)initWithPrivateToken:(NSString *)privateToken
{
    self = [super init];
    if (self) {
        _privateToken = privateToken;
    }
    
    return self;
}

- (id)initWithUserID:(int64_t)userID
{
    self = [super init];
    if (self) {
        _userID = userID;
    }
    
    return self;
}


#pragma mark - view life circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[EventCell class] forCellReuseIdentifier:EventCellIdentifier];
    self.tableView.backgroundColor = [Tools uniformColor];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    _manager = [AFHTTPRequestOperationManager GitManager];
    _manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    
    _events = [NSMutableArray new];
    _isFinishedLoad = NO;
    _page = 1;
    
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        [self fetchEvents:YES];
    }];
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _manager.requestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        [self fetchEvents:NO];
    }];
    
    [(MJRefreshAutoNormalFooter *)self.tableView.mj_footer setTitle:@"已全部加载完毕" forState:MJRefreshStateNoMoreData];
    // 默认先隐藏footer
    self.tableView.mj_footer.hidden = YES;
    
    _isFirstRequest = YES;
    
    /* 设置空页面状态 */
    [self fetchEvents:YES];
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    self.emptyDataSet.state = emptyViewState;
    __weak EventsView *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        weakSelf.manager.requestSerializer.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        [weakSelf fetchEvents:YES];
    };
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchEvents:(BOOL)refresh
{
    self.emptyDataSet.state = emptyViewState;
    
    if (refresh) {
        _page = 1;
    } else {
        _page++;
    }
    
    NSString *strUrl;
    if (_privateToken) {
        strUrl = [NSString stringWithFormat:@"%@%@?private_token=%@&page=%ld",
                  GITAPI_HTTPS_PREFIX,
                  GITAPI_EVENTS,
                  _privateToken,
                  (long)_page];
    } else {
        strUrl = [NSString stringWithFormat:@"%@%@/user/%lld?page=%ld",
                  GITAPI_HTTPS_PREFIX,
                  GITAPI_EVENTS,
                  _userID,
                  (long)_page];
    }
    
    [_manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (refresh) {
                 [_events removeAllObjects];
             }
             
             if ([responseObject count] > 0) {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLEvent *event = [[GLEvent alloc] initWithJSON:obj];
                     [_events addObject:event];
                 }];
                 
             }
             
             if (_events.count < 20) {
                 [self.tableView.mj_footer endRefreshingWithNoMoreData];
             } else {
                 [self.tableView.mj_footer endRefreshing];
             }
             
             if (_events.count == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有相关动态";
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

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _events.count) {
        GLEvent *event = [self.events objectAtIndex:indexPath.row];
        
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        [label setAttributedText:[Event getEventDescriptionForEvent:event]];
        CGFloat descriptionHeight = [label sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 60, MAXFLOAT)].height;
        
        CGFloat abstractHeight = 0;
        UITextView *textView = [UITextView new];
        textView.editable = NO;
        textView.scrollEnabled = NO;
        
        [Event setAbstractContent:textView forEvent:event];
        abstractHeight = [textView sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 60, MAXFLOAT)].height;
        
        return descriptionHeight + abstractHeight + 47;
    } else {
        return 60;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < _events.count) {
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier forIndexPath:indexPath];
        
        GLEvent *event = [self.events objectAtIndex:indexPath.row];
        
        [Tools setPortraitForUser:event.author view:cell.userPortrait cornerRadius:5.0];
        UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(tapPortrait:)];
        cell.userPortrait.tag = indexPath.row;
        cell.userPortrait.userInteractionEnabled = YES;
        [cell.userPortrait addGestureRecognizer:tapPortraitRecognizer];
        
        [cell generateEventDescriptionView:event];
        
        [cell.time setAttributedText:[Tools getIntervalAttrStr:event.createdAt]];
        
        cell.eventAbstract.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapsEventAbstract = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickToDetailProject:)];
        [cell.eventAbstract addGestureRecognizer:tapsEventAbstract];
        [Event setAbstractContent:cell.eventAbstract forEvent:event];
        cell.eventAbstract.tag = indexPath.row * 10;
        
        return cell;
    } else {
        return [UITableViewCell new];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    
    if (row < self.events.count) {
        GLEvent *event = [self.events objectAtIndex:indexPath.row];
        ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectID:event.projectId projectNameSpace:event.project.nameSpace];
        [projectDetails setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:projectDetails animated:YES];
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
    GLEvent *event = [self.events objectAtIndex:((UIImageView *)sender.view).tag];
    
    TitleScrollViewController *ownDetailsView = [[TitleScrollViewController alloc] initWithTitle:event.author.name
                                                                                    andSubTitles:@[@"动态", @"项目", @"Star", @"Watch"]
                                                                               andSubControllers:@[
                                                                                                   [[EventsView alloc] initWithUserID:event.author.userId],                                                                                                   [[ProjectsTableController alloc] initWithUserID:event.author.userId andProjectsType:ProjectsTypeUserProjects],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:event.author.userId andProjectsType:ProjectsTypeStared],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:event.author.userId andProjectsType:ProjectsTypeWatched]
                                                                                                   ]
                                                                                  andUnderTabbar:NO
                                                                                 andUserPortrait:NO];
    ownDetailsView.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:ownDetailsView animated:YES];
}


#pragma mark - 同cell点击事件一致
- (void)clickToDetailProject:(UITapGestureRecognizer *)sender
{
    GLEvent *event = [self.events objectAtIndex:(((UITextView *)sender.view).tag/10)];
    ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectID:event.projectId projectNameSpace:event.project.nameSpace];
    [projectDetails setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:projectDetails animated:YES];
}

@end
