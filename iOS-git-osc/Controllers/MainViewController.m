//
//  MainViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/23.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "LanguageSearchView.h"
#import "TitleScrollViewController.h"
#import "EventsView.h"
#import "ProjectsTableController.h"

@interface MainViewController () <UITabBarControllerDelegate, UITabBarDelegate>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *selectedImages;
@property (nonatomic, strong) NSUserDefaults *user;

@property (nonatomic, assign) NSString *privateToken;

@property ProjectsTableController *recommendedProjects;
@property ProjectsTableController *hotProjects;
@property ProjectsTableController *recentUpdatedProjects;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titles = @[@"项目", @"发现", @"我的"];
    _images = @[@"projects", @"discover", @"mine"];
    _selectedImages = @[@"projects_selected", @"discover_selected", @"mine_selected"];
    
    TitleScrollViewController *titleScrollCtl = [[TitleScrollViewController alloc] initWithTitle:@"项目"
                                                                                    andSubTitles:@[@"推荐", @"热门", @"最近更新"]
                                                                               andSubControllers:@[
                                                                                                   [[ProjectsTableController alloc] initWithProjectsType:ProjectsTypeFeatured],
                                                                                                   [[ProjectsTableController alloc] initWithProjectsType:ProjectsTypePopular],
                                                                                                   [[ProjectsTableController alloc] initWithProjectsType:ProjectsTypeLatest]
                                                                                                   ]
                                                                                  andUnderTabbar:YES
                                                                                 andUserPortrait:NO];

    titleScrollCtl.tabBarItem.title = _titles[0];

    titleScrollCtl.tabBarItem.image = [[UIImage imageNamed:_images[0]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    titleScrollCtl.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", _images[0]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationController *projectsNavigationController = [[UINavigationController alloc] initWithRootViewController:titleScrollCtl];
    
    LanguageSearchView *languageSearchView = [LanguageSearchView new];
    languageSearchView.tabBarItem.title = _titles[1];
    languageSearchView.tabBarItem.image = [[UIImage imageNamed:_images[1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    languageSearchView.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", _images[1]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationController *languageNavigationController = [[UINavigationController alloc] initWithRootViewController:languageSearchView];

    
    _user = [NSUserDefaults standardUserDefaults];
    int64_t userID = [[_user objectForKey:@"id"] intValue];
    _privateToken = [_user objectForKey:@"private_token"];
    
    TitleScrollViewController *ownDetailsView = [[TitleScrollViewController alloc] initWithTitle:@"我的"
                                                                                    andSubTitles:@[@"动态", @"项目", @"Star", @"Watch"]
                                                                               andSubControllers:@[
                                                                                                   [[EventsView alloc] initWithPrivateToken:_privateToken],
                                                                                                   [[ProjectsTableController alloc] initWithPrivateToken:_privateToken],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:userID andProjectsType:ProjectsTypeStared],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:userID andProjectsType:ProjectsTypeWatched]
                                                                                                   ]
                                                                                  andUnderTabbar:YES
                                                                                 andUserPortrait:YES];
    ownDetailsView.tabBarItem.title = _titles[2];
    ownDetailsView.tabBarItem.image = [[UIImage imageNamed:_images[2]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    ownDetailsView.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@_selected", _images[2]]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationController *ownNavigationController = [[UINavigationController alloc] initWithRootViewController:ownDetailsView];
    
    self.viewControllers = @[projectsNavigationController, languageNavigationController, ownNavigationController];
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - 检查是否登录

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (viewController == tabBarController.viewControllers[2]  && _privateToken == nil) {
        
        LoginViewController *loginViewController = [LoginViewController new];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginViewController];
        [((UINavigationController *)tabBarController.selectedViewController) presentViewController:nav animated:YES completion:nil];
        
        return NO;
    } else {
        return YES;
    }
}

@end
