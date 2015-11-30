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
#import "UIColor+Util.h"
#import "Tools.h"
#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "GLCommit.h"
#import "LastCell.h"
#import "HCDropdownView.h"

@interface ProjectsCommitsViewController () <HCDropdownViewDelegate>

@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *projectNameSpace;
@property (nonatomic, strong) NSMutableArray *commits;

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isFinishedLoad;
@property (nonatomic, strong) LastCell *lastCell;

@property (nonatomic, strong) HCDropdownView *branchTableView;
@property (nonatomic, strong) NSMutableArray *branchs;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) BOOL didChangeSelecteItem;
@property (nonatomic) CGPoint origin;
@property (nonatomic, copy) NSString *branchName;

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
    
    _branchs = [NSMutableArray new];
    _branchName = @"master";
    
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.navigationItem.title = @"master";
    _commits = [NSMutableArray new];
    
    [self.tableView registerClass:[ProjectsCommitCell class] forCellReuseIdentifier:cellId];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    _lastCell = [[LastCell alloc] initCell];
    
    [self fetchForCommitDataOnPage:1 refresh:YES];
    [self fetchbranchs:@"branches"];
    [self fetchbranchs:@"tags"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分支" style:UIBarButtonItemStylePlain target:self action:@selector(clickBranch)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 侧栏列表
- (void)initBranchTableView
{
    self.branchTableView = [HCDropdownView dropdownView];
    self.branchTableView.delegate = self;

    self.branchTableView.menuRowHeight = 50;
    self.branchTableView.titles = _branchs;
    self.branchTableView.imageNameStr = @"projectDetails_fork";
    self.branchTableView.menuTabelView.frame = CGRectMake(CGRectGetWidth([[UIScreen mainScreen]bounds])/2, 0, CGRectGetWidth([[UIScreen mainScreen]bounds])/2, MIN(CGRectGetHeight([[UIScreen mainScreen]bounds])/2, self.branchTableView.menuRowHeight * self.branchTableView.titles.count));
    self.branchTableView.menuTabelView.rowHeight = self.branchTableView.menuRowHeight;
    _origin = _branchTableView.menuTabelView.frame.origin;
}

#pragma mark - 分支
- (void)clickBranch
{
    [self initBranchTableView];
    
    BOOL isOpenedState;
    if ([self.branchTableView isOpen]) {
        [self.branchTableView hide];
        isOpenedState = NO;
    }
    else {
        [self.branchTableView showFromNavigationController:self.navigationController menuTabelViewOrigin:_origin];
        isOpenedState = YES;
    }
    
    NSLog(@"branch");
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
    
    NSString *strUrl = privateToken.length ? [NSString stringWithFormat:@"%@%@/%@/repository/commits?private_token=%@&page=%lu&ref_name=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, [Tools getPrivateToken], (unsigned long)page, _branchName] : [NSString stringWithFormat:@"%@%@/%@/repository/commits?page=%lu&ref_name=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, (unsigned long)page, _branchName];

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

- (void)fetchbranchs:(NSString *)branch
{
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    }
    
    [self.view makeToastActivity];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [user objectForKey:@"private_token"];
    
    NSString *strUrl = privateToken.length ? [NSString stringWithFormat:@"%@%@/%@/repository/%@?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, branch, [Tools getPrivateToken]] : [NSString stringWithFormat:@"%@%@/%@/repository/%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, branch];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             [self.view hideToastActivity];
             
             if ([responseObject count] == 0) {

             } else {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     NSString *name = [obj objectForKey:@"name"];
                    
                     [_branchs addObject:name];
                 }];
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                     
                 });
             }

         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             [self.view hideToastActivity];
             
             if (error != nil) {
                 [Tools toastNotification:[NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code] inView:self.view];
             } else {
                 [Tools toastNotification:@"网络错误" inView:self.view];
             }
             dispatch_async(dispatch_get_main_queue(), ^{

                 [self.tableView reloadData];
        
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

#pragma mark -- HCDropdownViewDelegate
- (void)dropdownViewWillHide:(HCDropdownView *)dropdownView {
    _didChangeSelecteItem = NO;
}
- (void)dropdownViewDidHide:(HCDropdownView *)dropdownView {
    if (_didChangeSelecteItem) {

        _branchName = _branchs[_selectedRow];
        [self fetchForCommitDataOnPage:1 refresh:YES];
        
        self.navigationItem.title = _branchName;
        
        [self.tableView reloadData];
    }
}
-(void)didSelectItemAtRow:(NSInteger)row {
    if (_selectedRow != row) {
        _didChangeSelecteItem = YES;
        _selectedRow = row;
    }

}

-(void)viewWillDisappear:(BOOL)animated {
    if (self.branchTableView) {
        [self.branchTableView hide];
    }
}

@end
