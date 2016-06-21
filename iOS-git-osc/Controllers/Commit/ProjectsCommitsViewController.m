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
#import "HCDropdownView.h"
#import "CommitDetailViewController.h"

#import "MJRefresh.h"
#import "DataSetObject.h"

@interface ProjectsCommitsViewController () <HCDropdownViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *projectNameSpace;
@property (nonatomic, strong) NSMutableArray *commits;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, assign) BOOL needRefresh;

@property (nonatomic, strong) HCDropdownView *branchTableView;
@property (nonatomic, strong) NSMutableArray *branchs;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, assign) NSInteger selectedRow;
@property (nonatomic, assign) BOOL didChangeSelecteItem;
@property (nonatomic) CGPoint origin;
@property (nonatomic, copy) NSString *branchName;
@property (nonatomic, assign) BOOL isClickBranch;

@property (nonatomic, strong) DataSetObject *emptyDataSet;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _branchs = [NSMutableArray new];
    _images = [NSMutableArray new];
    _branchName = @"master";
    
    _page = 1;
    
    self.navigationItem.title = @"master";
    self.view.backgroundColor = [UIColor uniformColor];
    _commits = [NSMutableArray new];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-64)];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [Tools uniformColor];
    [self.tableView registerClass:[ProjectsCommitCell class] forCellReuseIdentifier:cellId];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchForCommitDataOnRefresh:YES];
    }];
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchForCommitDataOnRefresh:NO];
    }];
    [(MJRefreshAutoNormalFooter *)self.tableView.mj_footer setTitle:@"已全部加载完毕" forState:MJRefreshStateNoMoreData];
    // 默认先隐藏footer
    self.tableView.mj_footer.hidden = YES;
    
    [self fetchForCommitDataOnRefresh:YES];
    [self fetchbranchs:@"branches"];
    [self fetchbranchs:@"tags"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分支" style:UIBarButtonItemStylePlain target:self action:@selector(clickBranch)];
    
    
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    self.emptyDataSet.state = emptyViewState;
    __weak ProjectsCommitsViewController *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchForCommitDataOnRefresh:YES];
    };
    _isClickBranch = YES;
    [self.tableView.mj_header beginRefreshing];
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
    self.branchTableView.images = _images;
    self.branchTableView.menuTabelView.frame = CGRectMake(CGRectGetWidth([[UIScreen mainScreen]bounds])/2, 0, CGRectGetWidth([[UIScreen mainScreen]bounds])/2, MIN(CGRectGetHeight([[UIScreen mainScreen]bounds])/2, self.branchTableView.menuRowHeight * self.branchTableView.titles.count));
    self.branchTableView.menuTabelView.rowHeight = self.branchTableView.menuRowHeight;
    _origin = _branchTableView.menuTabelView.frame.origin;
}

#pragma mark - 分支
- (void)clickBranch
{
    if (_isClickBranch) {
        [self initBranchTableView];

        [self.branchTableView showFromNavigationController:self.navigationController menuTabelViewOrigin:_origin];
        _isClickBranch = NO;
        
    } else {
        if ([self.branchTableView isOpen]) {
            [self.branchTableView hide];
        }
    }
}

#pragma mark - 获取数据
- (void)fetchForCommitDataOnRefresh:(BOOL)refresh
{
    self.emptyDataSet.state = emptyViewState;
    if (refresh) {
        _page = 1;
    } else {
        _page++;
    }
        
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [user objectForKey:@"private_token"];
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectID];
    
    NSString *strUrl;
    if (privateToken.length > 0) {
        strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/commits?private_token=%@&page=%ld&ref_name=%@",
                  GITAPI_HTTPS_PREFIX,
                  GITAPI_PROJECTS,
                  projectIdStr,
                  [Tools getPrivateToken],
                  (long)_page,
                  _branchName];
    } else {
        strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/commits?page=%ld&ref_name=%@",
                  GITAPI_HTTPS_PREFIX,
                  GITAPI_PROJECTS,
                  projectIdStr,
                  (long)_page,
                  _branchName];
    }


    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             
             if (refresh) {
                 [_commits removeAllObjects];
             }
             
             if ([responseObject count]) {

                 [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
                     GLCommit *commit = [[GLCommit alloc] initWithJSON:obj];
                     [_commits addObject:commit];
                 }];
  
             }
             
             if (_commits.count < 20) {
                 [self.tableView.mj_footer endRefreshingWithNoMoreData];
             } else {
                 [self.tableView.mj_footer endRefreshing];
             }

             
             if (_commits.count == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有提交记录";
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

#pragma mark - 获取分支信息

- (void)fetchbranchs:(NSString *)branch
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [user objectForKey:@"private_token"];
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectID];
    
    NSString *strUrl = privateToken.length ? [NSString stringWithFormat:@"%@%@/%@/repository/%@?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, projectIdStr, branch, [Tools getPrivateToken]] : [NSString stringWithFormat:@"%@%@/%@/repository/%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, projectIdStr, branch];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             
             if ([responseObject count] == 0) {

             } else {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     NSString *name = [obj objectForKey:@"name"];
                    
                     [_branchs addObject:name];
                     if ([branch isEqualToString:@"branches"]) {
                         [_images addObject:@"projectDetails_fork"];
                     } else {
                         [_images addObject:@"projectDetails_language"];
                     }
                 }];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
                 
             });

         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             dispatch_async(dispatch_get_main_queue(), ^{

                 [self.tableView reloadData];
        
             });
             
         }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _commits.count;
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
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)].height;
        
        return height + 58;
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
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = UIColorFromRGB(0xdadbdc);
        [cell setSelectedBackgroundView:selectedBackground];
        
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GLCommit *commit = _commits[indexPath.row];
    
    if (self.tableView == tableView) {
        CommitDetailViewController *commitDetailController = [CommitDetailViewController new];
        commitDetailController.projectNameSpace = _projectNameSpace;
        commitDetailController.commit = commit;
        commitDetailController.projectID = _projectID;
        [self.navigationController pushViewController:commitDetailController animated:YES];
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


#pragma mark -- HCDropdownViewDelegate
- (void)dropdownViewWillHide:(HCDropdownView *)dropdownView {
    _didChangeSelecteItem = NO;
    _isClickBranch = YES;
}
- (void)dropdownViewDidHide:(HCDropdownView *)dropdownView {
    if (_didChangeSelecteItem) {
        _needRefresh = YES;
        _branchName = _branchs[_selectedRow];
        [self fetchForCommitDataOnRefresh:YES];
        
        self.navigationItem.title = _branchName;
        
        [self.tableView reloadData];
    }
}
-(void)didSelectItemAtRow:(NSInteger)row
{
    _didChangeSelecteItem = YES;
    _selectedRow = row;
}

-(void)viewWillDisappear:(BOOL)animated {
    if (self.branchTableView) {
        [self.branchTableView hide];
    }
}

@end
