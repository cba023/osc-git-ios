//
//  SearchView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-21.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "SearchView.h"
#import "ProjectsTableController.h"
#import "ProjectCell.h"
#import "GLGitlab.h"
#import "Project.h"
#import "Tools.h"
#import "ProjectDetailsView.h"
#import "NavigationController.h"
#import "LastCell.h"

@interface SearchView ()

@end

static NSString * const SearchResultsCellID = @"SearchResultsCell";
static NSString * const LastCellID = @"LastCell";


@implementation SearchView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"项目搜索";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(NavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];

    
    _projects = [NSMutableArray new];
    
    [self initSubviews];
    [self setAutoLayout];
    
    //适配iOS7uinavigationbar遮挡tableView的问题
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewDidUnload
{
    _resultsTable = nil;
    _searchBar = nil;
    [super viewDidUnload];
}

#pragma 搜索

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if (_searchBar.text.length == 0) {
        return;
    }
    [searchBar resignFirstResponder];
    //清空
    [self clear];
    [self doSearch];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
}

-(void)doSearch
{
    _isLoading = YES;
    __block BOOL done = NO;
    
    [[GLGitlabApi sharedInstance] searchProjectsByQuery:_searchBar.text
                                                   page:_projects.count/15+1
                                                success:^(id responseObject) {
                                                    [_searchBar resignFirstResponder];
                                                    if ([(NSArray *)responseObject count] < 15) {
                                                        _isLoadOver = YES;
                                                    }
                                                    [_projects addObjectsFromArray:responseObject];
                                                    done = YES;
                                                }
                                                failure:^(NSError *error) {
                                                    if (error != nil) {
                                                        NSLog(@"%@, Request failed", error);
                                                    } else {
                                                        NSLog(@"error == nil");
                                                    }
                                                    done = YES;
                                                }];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    _isLoading = NO;
    
    [self.resultsTable reloadData];
}

-(void)clear
{
    [_projects removeAllObjects];
    //[_resultsTable reloadData];
    _isLoading = NO;
    _isLoadOver = NO;
}

#pragma TableView things

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isLoadOver) {
        return _projects.count == 0 ? 1 : _projects.count;
    } else {
        return _projects.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 0
    if (_isLoadOver) {
        return _projects.count == 0 ? 60 : 48;
    } else {
        return indexPath.row < _projects.count ? 60 : 48;
    }
#else
    return 60;
#endif
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_projects.count > 0) {
        if (indexPath.row < _projects.count) {
            ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultsCellID forIndexPath:indexPath];
            
            GLProject *project = [_projects objectAtIndex:indexPath.row];
            
            [Tools setPortraitForUser:project.owner view:cell.portrait cornerRadius:5.0];
            cell.projectNameField.text = [NSString stringWithFormat:@"%@ / %@", project.owner.name, project.name];
            cell.projectDescriptionField.text = project.projectDescription;
            cell.languageField.text = project.language;
            cell.forksCount.text = [NSString stringWithFormat:@"%i", project.forksCount];
            cell.starsCount.text = [NSString stringWithFormat:@"%i", project.starsCount];
            
            return cell;
        } else {
            //return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"搜索完毕" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
            LastCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellID forIndexPath:indexPath];
            return cell;
        }
    } else {
        //return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"查无结果" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        LastCell *cell = [tableView dequeueReusableCellWithIdentifier:LastCellID forIndexPath:indexPath];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row < _projects.count) {
        GLProject *project = [_projects objectAtIndex:row];
        if (project) {
            ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] init];
            projectDetails.project = project;
            [self.navigationController pushViewController:projectDetails animated:YES];
        }
    }
}


- (void)initSubviews
{
    _searchBar = [UISearchBar new];
    _searchBar.placeholder = @"搜索项目";
    _searchBar.showsCancelButton = YES;
    _searchBar.delegate = self;
    [self.view addSubview:_searchBar];
    [_searchBar becomeFirstResponder];
    
    _resultsTable = [UITableView new];
    _resultsTable.dataSource = self;
    _resultsTable.delegate = self;
    [_resultsTable registerClass:[ProjectCell class] forCellReuseIdentifier:SearchResultsCellID];
    [_resultsTable registerClass:[LastCell class] forCellReuseIdentifier:LastCellID];
    [self.view addSubview:_resultsTable];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_searchBar]-[_resultsTable]-|"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_searchBar, _resultsTable)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[_searchBar]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_searchBar)]];
}


@end
