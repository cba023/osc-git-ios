//
//  MenuViewController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "MenuViewController.h"
#import "HomeViewController.h"
#import "NavigationController.h"
#import "LoginViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "Tools.h"
#import "GLGitlab.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
#if 0
        NSString *urlString = [NSString stringWithFormat: @"%@%@%@",
                               @"http://secure.gravatar.com/avatar/",
                               [Tools md5: user.email],
                                @"?s=90&d=mm"];
        
        imageView.image = [Tools loadImage: [NSURL URLWithString:urlString]];
#endif
        imageView.image = [UIImage imageNamed:@"avatar.jpg"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor clearColor].CGColor;
        imageView.layer.borderWidth = 0.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = @"Roman Efimov";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return nil;
    
    NSArray *headerNames = [NSArray arrayWithObjects:
                            @"", @"代码库", @"信息及设置", nil];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    label.text = headerNames[sectionIndex];
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0)
        return 0;
    
    return 34;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                HomeViewController *homeViewController = [[HomeViewController alloc] init];
                NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:homeViewController];
                self.frostedViewController.contentViewController = navigationController;
                break;
            }
                
            case 1: {
                break
            }
                
            default:
                break;
        }
    }*/
    if (indexPath.section == 0 && indexPath.row == 0) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:homeViewController];
        self.frostedViewController.contentViewController = navigationController;
    } else {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:loginViewController];
        self.frostedViewController.contentViewController = navigationController;
    }
    
    [self.frostedViewController hideMenuViewController];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    switch (sectionIndex) {
        case 0:
            return 3;
        case 1:
            return 2;
        case 2:
            return 3;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    NSArray *titles;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            titles = @[@"动态", @"项目", @"通知"];
            break;
        
        case 1:
            titles = @[@"星标", @"热门"];
            break;
        
        case 2:
            titles = @[@"账号", @"设置", @"关于我们"];
            break;
        
        default:
            break;
    }
    
    cell.textLabel.text = titles[indexPath.row];
    return cell;
}

@end
