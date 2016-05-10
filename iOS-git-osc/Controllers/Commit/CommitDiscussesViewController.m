//
//  CommitDiscussesViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/14.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "CommitDiscussesViewController.h"
#import "Tools.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "GITAPI.h"
#import "GLComment.h"
#import "NoteCell.h"
#import "UIColor+Util.h"

#import "MJRefresh.h"
#import "DataSetObject.h"
#import <MBProgressHUD.h>

@interface CommitDiscussesViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic,strong) DataSetObject *emptyDataSet;
@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) UITextField *commentField;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation CommitDiscussesViewController

static NSString * const NoteCellId = @"NoteCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"评论";
    _comments = [NSMutableArray new];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    self.tableView.backgroundColor = [Tools uniformColor];
    
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self fetchForDiscuss:YES];
    }];
    //上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self fetchForDiscuss:NO];
    }];
    [(MJRefreshAutoNormalFooter *)self.tableView.mj_footer setTitle:@"已全部加载完毕" forState:MJRefreshStateNoMoreData];
    // 默认先隐藏footer
    self.tableView.mj_footer.hidden = YES;
    _page = 1;

    [self.tableView registerClass:[NoteCell class] forCellReuseIdentifier:NoteCellId];
    [self fetchForDiscuss:YES];
    
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    self.emptyDataSet.state = emptyViewState;
    __weak CommitDiscussesViewController *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchForDiscuss:YES];
    };
    [self.tableView.mj_header beginRefreshing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(feedComment)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -获取数据
- (void)fetchForDiscuss:(BOOL)refresh
{
    self.emptyDataSet.state = emptyViewState;
    
    if (refresh) {
        _page = 1;
    } else {
        _page++;
    }
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectID];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/commits/%@/comment",
                                                   GITAPI_HTTPS_PREFIX,
                                                   GITAPI_PROJECTS,
                                                   projectIdStr,
                                                   _commitID];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"projectid"     : @(_projectID),
                                                                                      @"page"           : @(_page),
                                                                                      @"private_token" : [Tools getPrivateToken]
                                                                                      }];
    
    if ([Tools getPrivateToken].length == 0) {
        [parameters removeObjectForKey:@"private_token"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager GET:strUrl
      parameters:parameters
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (refresh) {
                 [_comments removeAllObjects];
             }
             
             if ([responseObject count] == 0) { } else {
                 [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLComment *comment = [[GLComment alloc] initWithJSON:obj];
                     
                     [_comments addObject:comment];
                 }];
             }
             
             if (_comments.count < 20) {
                 [self.tableView.mj_footer endRefreshingWithNoMoreData];
             } else {
                 [self.tableView.mj_footer endRefreshing];
             }
             
             if (_comments.count == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有评论";
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView.mj_header endRefreshing];
                 [self.tableView reloadData];
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

#pragma mark - 发表评论
- (void)feedComment
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发表" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发表", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    _commentField = [alertView textFieldAtIndex:0];
    _commentField.placeholder = @"请填写您的评价";
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self postForComment];
    }
}

- (void)postForComment
{
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = MBProgressHUDModeCustomView;
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectID];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/commits/%@/comment",
                                                  GITAPI_HTTPS_PREFIX,
                                                  GITAPI_PROJECTS,
                                                  projectIdStr,
                                                  _commitID];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      @"note"          : _commentField.text,
                                                                                      @"private_token" : [Tools getPrivateToken]
                                                                                      }];
    if ([Tools getPrivateToken].length == 0) {
        [parameters removeObjectForKey:@"private_token"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager POST:strUrl
       parameters:parameters
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              if ([responseObject count] > 0) {
                  _hud.labelText = @"发表成功";
                  [_hud hide:YES afterDelay:1.0];
              }
              GLComment *comment = [[GLComment alloc] initWithJSON:responseObject];
              
              [_comments addObject:comment];
              
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.tableView reloadData];
              });
          } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              _hud.labelText = @"发表失败";
              [_hud hide:YES afterDelay:1.0];
        }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_comments.count > 0) {
        GLComment *comment = _comments[indexPath.row];
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont systemFontOfSize:16];
        label.text = [Tools flattenHTML:comment.noteString];
        
        CGSize size = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 8, MAXFLOAT)];
        
        return size.height + 54;
    }
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_comments.count > 0) {
        NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:NoteCellId forIndexPath:indexPath];
        
        cell.backgroundColor = [UIColor uniformColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        GLComment *comment = _comments[indexPath.row];
        [cell contentForProjectsComment:comment];
        
        return cell;
    }
    return [UITableViewCell new];
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
