//
//  SetUpsViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/26.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "SetUpsViewController.h"
//#import "ShakingView.h"
#import "ShakingViewController.h"
#import "FeedBackViewController.h"
#import "AboutViewController.h"
#import "CacheProjectsUtil.h"

#import "UIColor+Util.h"

@interface SetUpsViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *titles;

@end

@implementation SetUpsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
    _titles = @[@"清除缓存", @"意见反馈", @"关于"];
    
    self.navigationItem.title = @"设置";
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.separatorColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else{
        return _titles.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    if (indexPath.section == 0) {
        cell.textLabel.text = @"摇一摇";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else {
        cell.textLabel.text = _titles[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        ShakingViewController *shakingView = [ShakingViewController new];
        [self.navigationController pushViewController:shakingView animated:YES];
        
    } else {
        switch (indexPath.row) {
            case 0:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"确定清除缓存？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"清除", nil];
                
                [alertView show];
                
                break;
            }
            case 1:
            {
                FeedBackViewController *feedBackViewController = [FeedBackViewController new];
                [self.navigationController pushViewController:feedBackViewController animated:YES];
                
                break;
            }
            case 2:
            {
                AboutViewController *aboutViewController = [AboutViewController new];
                [self.navigationController pushViewController:aboutViewController animated:YES];
                
                break;
            }
                
            default:
                break;
        }

    }
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        [[CacheProjectsUtil shareInstance] removeCache];
    }
}

@end
