//
//  MenuViewController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "MenuViewController.h"
#import "LoginViewController.h"
#import "GLGitlab.h"
#import "User.h"
#import "Event.h"
#import "Project.h"
#import "ProjectsViewController.h"
#import "ProjectsTableController.h"
#import "EventsView.h"
#import "IssuesView.h"
#import "AccountManagement.h"
#import "SearchView.h"
#import "LanguageSearchView.h"
#import "UIImageView+WebCache.h"
#import "UserDetailsView.h"
#import "ShakingView.h"
#import "PKRevealController.h"

@interface MenuViewController ()

@end

static NSString * const kKeyUserId = @"id";
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
    self.tableView.backgroundColor = UIColorFromRGB(0x363636);
    self.tableView.separatorStyle = NO;
    [self.revealController setMinimumWidth:200.0 maximumWidth:220.0 forViewController:self];
#if 0
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        if (portrait) {
            NSString *urlString = [git_osc_url stringByAppendingString:portrait];
            [self.imageView setImageWithURL:[NSURL URLWithString:urlString]];
        } else {
            self.imageView.image = [UIImage imageNamed:@"tx"];
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
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 40, 80, 80)];
        //self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        NSString *portrait = [self.user objectForKey:kKeyPortrait];
        NSString *name = [self.user objectForKey:kKeyName];
        
        if (portrait) {
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:portrait]];
        } else {
            self.imageView.image = [UIImage imageNamed:@"tx"];
        }
        
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 40.0;
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageView.layer.borderWidth = 0.0f;
        self.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.imageView.layer.shouldRasterize = YES;
        self.imageView.clipsToBounds = YES;
        
        UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(tapPortrait:)];
        [view addGestureRecognizer:tapPortraitRecognizer];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(80, 130, 0, 24)];
        if (name) {
            self.label.text = name;
        } else {
            self.label.text = @"游客";
        }
        self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        self.label.textColor = [UIColor whiteColor];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [self.label sizeToFit];
        //self.label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:self.imageView];
        [view addSubview:self.label];
        view;
    });
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];//[UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UINavigationController *front = [UINavigationController alloc];
    if (indexPath.row == 1) {
        NSString *privateToken = [self.user objectForKey:@"private_token"];
        if (privateToken == nil) {
            LoginViewController *loginViewController = [LoginViewController new];
            front = [front initWithRootViewController:loginViewController];
        } else {
            int64_t userID = [[self.user objectForKey:kKeyUserId] intValue];
            UserDetailsView *ownDetailsView = [[UserDetailsView alloc] initWithPrivateToken:privateToken userID:userID];
            front = [front initWithRootViewController:ownDetailsView];
        }
    } else {
        if (indexPath.row == 0) {
            ProjectsViewController *projectViewController = [ProjectsViewController new];
            front = [front initWithRootViewController:projectViewController];
        } else if (indexPath.row == 2) {
            LanguageSearchView *languageSearchView = [LanguageSearchView new];
            front = [front initWithRootViewController:languageSearchView];
        } else if (indexPath.row == 3) {
            SearchView *searchView = [SearchView new];
            front = [front initWithRootViewController:searchView];
        } else {
            ShakingView *shakingView = [ShakingView new];
            front = [front initWithRootViewController:shakingView];
        }
    }
    
    [self.revealController setFrontViewController:front];
    [self.revealController showViewController:self.revealController.frontViewController];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    NSArray *titles;        //, *images;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    titles = @[@"发现", @"我的", @"语言", @"搜索", @"摇一摇"];
    //images = @[@"MenuProfile", @"MenuProfile", @"MenuOrgRepos", @"MenuOrgRepos", @"MenuOrgRepos", @"MenuOrgRepos"];
    //cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    cell.textLabel.text = titles[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark - recognizer
- (void)tapPortrait:(UITapGestureRecognizer *)recognizer
{
    UINavigationController *front = [UINavigationController alloc];
    
    if ([_user objectForKey:@"private_token"]) {
        AccountManagement *accountView = [AccountManagement new];
        front = [front initWithRootViewController:accountView];
    } else {
        LoginViewController *loginViewController = [LoginViewController new];
        front = [front initWithRootViewController:loginViewController];
    }
    
    [self.revealController setFrontViewController:front];
    [self.revealController showViewController:self.revealController.frontViewController];
}

@end
