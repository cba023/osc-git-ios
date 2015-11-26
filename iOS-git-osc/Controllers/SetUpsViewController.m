//
//  SetUpsViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/26.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "SetUpsViewController.h"
#import "ShakingView.h"
#import "AboutViewController.h"

#import "UIColor+Util.h"

@interface SetUpsViewController ()

@property (nonatomic, strong) NSArray *titlesCell;

@end

@implementation SetUpsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
    _titlesCell = @[@"摇一摇", @"关于"];
    
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

    return _titlesCell.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    
    cell.textLabel.text = _titlesCell[indexPath.section];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            ShakingView *shakingView = [ShakingView new];
            [self.navigationController pushViewController:shakingView animated:YES];
            
            break;
        }
        case 1:
        {
            AboutViewController *aboutViewController = [AboutViewController new];
            [self.navigationController pushViewController:aboutViewController animated:YES];
            
            break;
        }
        case 2:
        {
            break;
        }
           
        default:
            break;
    }
}

@end
