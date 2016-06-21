//
//  CommitDetailViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/2.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "CommitDetailViewController.h"
#import "GITAPI.h"
#import "Tools.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "GLDiff.h"
#import "UIColor+Util.h"
#import "UIView+Toast.h"
#import "DataSetObject.h"
#import "CommitDiscussesViewController.h"

#import "DiffHeaderCell.h"
#import "CommitFileViewController.h"
#import <MBProgressHUD.h>

@interface CommitDetailViewController ()

@property (nonatomic, strong) NSMutableArray *commitDiffs;
@property (nonatomic,strong) DataSetObject *emptyDataSet;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation CommitDetailViewController

static NSString * const cellId = @"DiffHeaderCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _commitDiffs = [NSMutableArray new];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.backgroundColor = [Tools uniformColor];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    [self fetchForCommitDiff];
    
    [self.tableView registerClass:[DiffHeaderCell class] forCellReuseIdentifier:cellId];
    
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    __weak CommitDetailViewController *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchForCommitDiff];
    };
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"评论" style:UIBarButtonItemStylePlain target:self action:@selector(commitForDiscuss)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


#pragma mark - 讨论页面
- (void)commitForDiscuss
{
    CommitDiscussesViewController *commitDiscussViewController = [CommitDiscussesViewController new];
    commitDiscussViewController.projectNameSpace = _projectNameSpace;
    commitDiscussViewController.commitID = _commit.sha;
    commitDiscussViewController.projectID = _projectID;
    [self.navigationController pushViewController:commitDiscussViewController animated:YES];
}

#pragma mark - 获取数据
- (void)fetchForCommitDiff
{
    self.emptyDataSet.state = loadingState;
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectID];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/commits/%@/diff",
                       GITAPI_HTTPS_PREFIX,
                       GITAPI_PROJECTS,
                       projectIdStr,
                       _commit.sha];
    if ([Tools getPrivateToken].length > 0) {
        strUrl = [NSString stringWithFormat:@"%@?private_token=%@", strUrl, [Tools getPrivateToken]];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             
             if ([responseObject count] > 0) {
                 [responseObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLDiff *diff = [[GLDiff alloc] initWithJSON:obj];
                     
                     [_commitDiffs addObject:diff];
                 }];
             }
             
             if (_commitDiffs.count == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有提交文件";
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
             
         } failure:^(AFHTTPRequestOperation * operation, NSError * error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.emptyDataSet.state = netWorkingErrorState;
                 [self.tableView reloadData];
             });
    }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (_commitDiffs.count > 0) {
        if (section == 0) {
            return 1;
        }
        return _commitDiffs.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont boldSystemFontOfSize:16];
        label.text = _commit.title;
        CGFloat height = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 68, MAXFLOAT)].height;
        
        return height + 69;
    }
    return 60;
}

#pragma mark -- setupHeaderView
-(UIView*)setupHeaderViewWithTitle:(NSString*)title {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.frame), 35)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *opusPropertyHeaderLabel = [[UILabel alloc]initWithFrame:CGRectMake(13, 0, CGRectGetWidth(view.frame)-13, CGRectGetHeight(view.frame))];
    opusPropertyHeaderLabel.textColor = [UIColor colorWithHex:0x515151];
    opusPropertyHeaderLabel.font = [UIFont boldSystemFontOfSize:16];
    opusPropertyHeaderLabel.text = title;
    [view addSubview:opusPropertyHeaderLabel];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        NSString *str = [NSString stringWithFormat:@"%lu个文件发生了改变", (unsigned long)_commitDiffs.count];
        return [self setupHeaderViewWithTitle:str];
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1 || section == 2 || section == 3) {
        return 35;
    }
    return 0.001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DiffHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell contentForProjectsCommit:_commit];
        
        return cell;
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
        }
        
        cell.backgroundColor = [UIColor uniformColor];
        cell.textLabel.textColor = [UIColor colorWithHex:0x515151];
        cell.detailTextLabel.textColor = [UIColor colorWithHex:0xb6b6b6];
        
        if (_commitDiffs.count > 0) {
            GLDiff *diff = _commitDiffs[indexPath.row];
            if ([diff.updatedPath rangeOfString:@"/"].location != NSNotFound) {
                NSArray *array = [diff.updatedPath componentsSeparatedByString:@"/"];
                NSString *lastString = array[array.count-1];
                
                cell.textLabel.text = diff.updatedPath;
                cell.detailTextLabel.text = [diff.updatedPath substringToIndex:diff.updatedPath.length-lastString.length-1];
            } else {
                cell.textLabel.text = diff.updatedPath;
                cell.detailTextLabel.text = diff.updatedPath;
            }
            
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        GLDiff *diff = _commitDiffs[indexPath.row];
        
        if (diff.type == GLDiffTypeText) {
            CommitFileViewController *commitFileController = [CommitFileViewController new];
            commitFileController.projectNameSpace = _projectNameSpace;
            commitFileController.commitIDStr = _commit.sha;
            commitFileController.commitFilePath = diff.updatedPath;
            [self.navigationController pushViewController:commitFileController animated:YES];
        }
        
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
