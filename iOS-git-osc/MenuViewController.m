//
//  MenuViewController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "MenuViewController.h"
#import "NavigationController.h"
#import "LoginViewController.h"
#import "UIViewController+REFrostedViewController.h"
#import "GLGitlab.h"
#import "User.h"
#import "Event.h"
#import "Project.h"
#import "ProjectsViewController.h"
#import "ProjectsTableController.h"
#import "EventsView.h"
#import "IssuesView.h"
#import "AccountManagement.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface MenuViewController ()

@end

static NSString * const kKeyName = @"name";
static NSString * const kKeyPortrait = @"new_portrait";

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
    self.tableView.separatorStyle = NO;
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
            [self.imageView setImageWithURL:[NSURL URLWithString:portrait]];
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
        
        UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(tapPortrait:)];
        [view addGestureRecognizer:tapPortraitRecognizer];
        
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

#pragma mark - UITableView Delegate

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
                            @"", @"发现", @"设置", nil];
    
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
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                EventsView *eventsView = [EventsView new];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *privateToken = [userDefaults objectForKey:@"private_token"];
                if (privateToken == nil) {
                    NSLog(@"No private_token!");
                    break;
                } else {
                    eventsView.events = [[NSMutableArray alloc] initWithArray:[Event getEventsWithPrivateToekn:privateToken page:1]];
                }

                NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:eventsView];
                self.frostedViewController.contentViewController = navigationController;
                break;
            }
            case 1: {
                ProjectsTableController *ownProjectsView = [[ProjectsTableController alloc] init];
                ownProjectsView.personal = YES;
                NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:ownProjectsView];
                self.frostedViewController.contentViewController = navigationController;
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        ProjectsViewController *projectViewController = [[ProjectsViewController alloc] init];
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:projectViewController];
        self.frostedViewController.contentViewController = navigationController;
    } else {
        IssuesView *issuesView = [[IssuesView alloc] init];
        issuesView.projectId = 82;
        NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:issuesView];
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
            return 5;
        case 1:
            return 2;
        case 2:
            return 1;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    NSArray *titles, *images;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            titles = @[@"动态", @"项目", @"收藏", @"关注", @"通知"];
            images = @[@"MenuProfile", @"MenuRepositories", @"MenuStarredRepos", @"MenuWatchedRepos", @"MenuIssues"];
            cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
            break;
        
        case 1:
            titles = @[@"广场", @"搜索"];
            break;
        
        case 2:
            titles = @[@"偏好设置"];
            break;
        
        default:
            break;
    }
    
    cell.textLabel.text = titles[indexPath.row];
    return cell;
}

#pragma mark - recognizer
- (void)tapPortrait:(UITapGestureRecognizer *)recognizer
{
    NavigationController *navigationController;
    
    if ([_user objectForKey:@"private_token"]) {
        AccountManagement *accountView = [AccountManagement new];
        navigationController = [[NavigationController alloc] initWithRootViewController:accountView];
    } else {
        LoginViewController *loginViewController = [LoginViewController new];
        navigationController = [[NavigationController alloc] initWithRootViewController:loginViewController];
    }
    
    self.frostedViewController.contentViewController = navigationController;
    [self.frostedViewController hideMenuViewController];
}

@end
