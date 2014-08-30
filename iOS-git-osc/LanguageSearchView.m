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
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            _languages = responseObject;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });

        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
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
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectsTableController *projectsTC = [ProjectsTableController new];
    GLLanguage *language = [_languages objectAtIndex:indexPath.row];
    
    projectsTC.title = language.name;
    projectsTC.projectsType = 6;
    projectsTC.languageID = language.languageID;
    
    [self.navigationController pushViewController:projectsTC animated:YES];
}


@end
