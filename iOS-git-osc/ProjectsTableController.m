//
//  ProjectsTableController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectsTableController.h"
#import "ProjectCell.h"
#import "FilesTableController.h"
#import "NavigationController.h"
#import "ProjectDetailsView.h"
#import "GLGitlab.h"
#import "Project.h"
#import "Tools.h"

@interface ProjectsTableController ()

@end

@implementation ProjectsTableController
@synthesize projectsArray;
//@synthesize loadingMore;

static NSString * const cellId = @"ProjectCell";

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
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
    self.title = @"个人项目";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[ProjectCell class] forCellReuseIdentifier:cellId];
    self.navigationController.navigationBar.translucent = NO;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    self.projectsArray = [NSMutableArray new];
    [self.projectsArray addObjectsFromArray:[Project loadProjectsType:_projectsType page:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 表格显示及操作

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    GLProject *project = [self.projectsArray objectAtIndex:indexPath.row];
    
    [Tools setPortraitForUser:project.owner view:cell.portrait cornerRadius:5.0];
    cell.projectNameField.text = [NSString stringWithFormat:@"%@ / %@", project.owner.name, project.name];
    cell.projectDescriptionField.text = project.projectDescription;
    cell.languageField.text = project.language;
    cell.forksCount.text = [NSString stringWithFormat:@"%i", project.forksCount];
    cell.starsCount.text = [NSString stringWithFormat:@"%i", project.starsCount];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    if (row < self.projectsArray.count) {
        GLProject *project = [projectsArray objectAtIndex:row];
        if (project) {
            ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] init];
            projectDetails.project = project;
            if (_projectsType > 2) {
                [self.navigationController pushViewController:projectDetails animated:YES];
            } else {
                [self.parentViewController.navigationController pushViewController:projectDetails animated:YES];
            }
        }
    }
}


#pragma mark - 基本数值设置

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projectsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


#pragma mark - 上拉加载更多

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 下拉到最底部时显示更多数据
	if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
	{
        BOOL reload = NO;
        NSUInteger page = projectsArray.count/20 + 1;
        if (_projectsType > 2 && [projectsArray count]%20 == 0) {
            NSArray *nextPageProjects = [Project getOwnProjectsOnPage:page];
            if (nextPageProjects) {
                [projectsArray addObjectsFromArray:nextPageProjects];
            }
            reload = YES;
        } else if (_projectsType < 2){
            [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType onPage:page]];
            reload = YES;
        }
        if (reload) {[self.tableView reloadData];}
	}
}


#pragma mark - 刷新

- (void)refreshView:(UIRefreshControl *)refreshControl
{
    // http://stackoverflow.com/questions/19683892/pull-to-refresh-crashes-app helps a lot
    
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        [self.projectsArray removeAllObjects];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.projectsArray addObjectsFromArray:[Project loadProjectsType:_projectsType page:1]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                
                refreshInProgress = NO;
            });
        });
    }
}

- (void)reloadType:(NSInteger)newArrangeType
{
    self.arrangeType = newArrangeType;
    [self.projectsArray removeAllObjects];
    
    [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType onPage:1]];
    [self.tableView reloadData];
}

@end
