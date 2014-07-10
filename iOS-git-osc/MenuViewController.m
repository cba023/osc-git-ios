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
#import "GLGitlab.h"
#import "User.h"
#import "Project.h"
#import "ProjectsViewController.h"
#import "EventsView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MenuViewController ()

@end

static NSString * const kKeyName = @"name";
static NSString * const kKeyPortrait = @"portrait";

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.user = [NSUserDefaults standardUserDefaults];
    
    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
#if 0
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        if (portrait) {
            NSString *urlString = [git_osc_url stringByAppendingString:portrait];
            [self.imageView setImageWithURL:[NSURL URLWithString:urlString]];
        } else {
            self.imageView.image = [UIImage imageNamed:@"avatar.jpg"];
        }
        
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 50.0;
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageView.layer.borderWidth = 0.0f;
        self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.imageView.layer.shouldRasterize = YES;
        self.imageView.clipsToBounds = YES;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        if (name) {
            self.label.text = name;
        } else {
            self.label.text = @"游客";
        }
        self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [self.label sizeToFit];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:self.imageView];
        [view addSubview:self.label];
        view;
    });
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        NSString *portrait = [self.user objectForKey:kKeyPortrait];
        NSString *name = [self.user objectForKey:kKeyName];
        
        if (portrait) {
            NSString *urlString = [NSString stringWithFormat:@"%@%@%@", git_osc_url, @"//", portrait];//[git_osc_url stringByAppendingString:portrait];
            [self.imageView setImageWithURL:[NSURL URLWithString:urlString]];
        } else {
            self.imageView.image = [UIImage imageNamed:@"avatar.jpg"];
        }
        
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 50.0;
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageView.layer.borderWidth = 0.0f;
        self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.imageView.layer.shouldRasterize = YES;
        self.imageView.clipsToBounds = YES;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        if (name) {
            self.label.text = name;
        } else {
            self.label.text = @"游客";
        }
        self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [self.label sizeToFit];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:self.imageView];
        [view addSubview:self.label];
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
    if (indexPath.section == 0 && indexPath.row == 1) {
        HomeViewController *homeViewController = [[HomeViewController alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:homeViewController];
        self.frostedViewController.contentViewController = navigationController;
    } else if (indexPath.section == 0 && indexPath.row == 0) {
        EventsView *eventsView = [[EventsView alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:eventsView];
        self.frostedViewController.contentViewController = navigationController;
    }
    else if (indexPath.section == 0 && indexPath.row > 1) {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:loginViewController];
        self.frostedViewController.contentViewController = navigationController;
    } else {
#if 0
        ProjectTableController *projectTableController = [[ProjectTableController alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:projectTableController];
        self.frostedViewController.contentViewController = navigationController;
#endif
        ProjectsViewController *projectViewController = [[ProjectsViewController alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:projectViewController];
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
