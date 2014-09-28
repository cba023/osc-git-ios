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
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = UIColorFromRGB(0x272727);
    self.tableView.separatorStyle = NO;
    self.tableView.bounces = NO;
    [self.revealController setMinimumWidth:200.0 maximumWidth:220.0 forViewController:self];
    
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        
        _imageView = [UIImageView new];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 40.0;
        _imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        _imageView.layer.shouldRasterize = YES;
        _imageView.clipsToBounds = YES;
        [view addSubview:_imageView];
        
        _label = [UILabel new];
        _label.translatesAutoresizingMaskIntoConstraints = NO;
        _label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        _label.textColor = UIColorFromRGB(0xebebf3);
        _label.backgroundColor = [UIColor clearColor];
        [view addSubview:_label];
        
        NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_imageView, _label);
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[_imageView(80)]-[_label]"
                                                                     options:NSLayoutFormatAlignAllCenterX
                                                                     metrics:nil
                                                                       views:viewsDict]];
        
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-60-[_imageView(80)]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:viewsDict]];
        
        UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(tapPortrait:)];
        [view addGestureRecognizer:tapPortraitRecognizer];
        
        view;
    });

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *portrait = [self.user objectForKey:kKeyPortrait];
    NSString *name = [self.user objectForKey:kKeyName];
    
    if (portrait) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:portrait]];
    } else {
        self.imageView.image = [UIImage imageNamed:@"userNotLoggedIn"];
    }
    
    if (name) {
        self.label.text = name;
    } else {
        self.label.text = @"点击登录";
    }
    [self.label sizeToFit];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = UIColorFromRGB(0xebebf3);
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
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = UIColorFromRGB(0x252525);
    [cell setSelectedBackgroundView:selectedBackground];
    
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
