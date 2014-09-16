//
//  LanguageSearchView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-22.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "LanguageSearchView.h"
#import "GLGitlab.h"
#import "Project.h"
#import "NavigationController.h"
#import "ProjectsTableController.h"
#import "UIView+Toast.h"
#import "Tools.h"

@interface LanguageSearchView ()

@end

static NSString * const LanguageCellID = @"LanguageCell";

@implementation LanguageSearchView

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(NavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
    self.title = @"编程语言";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LanguageCellID];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    self.tableView.bounces = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_languages.count > 0) {
        return;
    }
    
    if ([Tools isPageCacheExist:10]) {
        [self loadFromCache];
        [self.view hideToastActivity];
        return;
    }
    
    [self.view makeToastActivity];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        [self.view hideToastActivity];
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            _languages = responseObject;
            [Tools savePageCache:_languages type:10];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        [self.view hideToastActivity];
        [Tools toastNotification:@"网络错误" inView:self.view];
    };
    
    [[GLGitlabApi sharedInstance] getLanguagesListSuccess:success failure:failure];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _languages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LanguageCellID forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    for (UIView *subview in [cell.contentView subviews]) {
        [subview removeFromSuperview];
    }
    
    UILabel *languageName = [UILabel new];
    GLLanguage *language = [_languages objectAtIndex:indexPath.row];
    languageName.text = language.name;
    [cell.contentView addSubview:languageName];
    
    languageName.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[languageName]-5-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(languageName)]];
    
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[languageName]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(languageName)]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectsTableController *projectsTC = [[ProjectsTableController alloc] initWithProjectsType:6];
    GLLanguage *language = [_languages objectAtIndex:indexPath.row];
    
    projectsTC.title = language.name;
    projectsTC.languageID = language.languageID;
    
    [self.navigationController pushViewController:projectsTC animated:YES];
}


#pragma mark - 从缓存加载

- (void)loadFromCache
{
    _languages = [Tools getPageCache:10];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}




@end
