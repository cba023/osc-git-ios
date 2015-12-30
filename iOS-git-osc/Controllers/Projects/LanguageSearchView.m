//
//  LanguageSearchView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-22.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "LanguageSearchView.h"
#import "GLGitlab.h"
#import "ProjectsTableController.h"
#import "UIView+Toast.h"
#import "Tools.h"
#import "SearchView.h"
#import "CacheProjectsUtil.h"

#import "AFHTTPRequestOperationManager+Util.h"
#import "GITAPI.h"

@interface LanguageSearchView ()

@property (nonatomic, strong) NSMutableArray *languages;

@end

static NSString * const LanguageCellID = @"LanguageCell";

@implementation LanguageSearchView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                           target:self
                                                                                           action:@selector(showMenu)];
    self.title = @"发现";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:LanguageCellID];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    self.tableView.backgroundColor = [Tools uniformColor];
 
    if (![Tools isConnectionAcailable]) {
        _languages = (NSMutableArray *)[[CacheProjectsUtil shareInstance] readLanguageList];
        if (!_languages || _languages.count < 1) {
            _languages = [NSMutableArray new];
            [self fetchForLanguage];
        } else {
            [self.tableView reloadData];
        }
    } else {
        _languages = [NSMutableArray new];
        [self fetchForLanguage];
    }
}

- (void)showMenu
{
    SearchView *searchView = [SearchView new];
    
    [searchView setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:searchView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchForLanguage
{
    NSString *StrUrl = [NSString stringWithFormat:@"%@/%@/%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, GITAPI_LANGUAGE];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager GET:StrUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
             if ([responseObject count] > 0) {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLLanguage *language =[[GLLanguage alloc] initWithJSON:obj];
                     [_languages addObject:language];
                 }];
                 [[CacheProjectsUtil shareInstance] insertLanguageList:_languages];
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });

         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             NSLog(@"error = %@", error);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
    }];
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
    cell.backgroundColor = [Tools uniformColor];
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
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = UIColorFromRGB(0xdadbdc);
    [cell setSelectedBackgroundView:selectedBackground];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectsTableController *projectsTC = [[ProjectsTableController alloc] initWithProjectsType:ProjectsTypeLanguage];
    GLLanguage *language = [_languages objectAtIndex:indexPath.row];
    
    projectsTC.title = language.name;
    projectsTC.languageID = language.languageID;
    
    [projectsTC setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:projectsTC animated:YES];
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
