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
    
#if 0
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手更新数据"]];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    //[self setRefreshControl:self.refreshControl];
#endif
    
    self.projectsArray = [[NSMutableArray alloc] initWithCapacity:20];
    if (_personal) {
        [self.projectsArray addObjectsFromArray:[Project getOwnProjectsOnPage:1]];
    } else {
        [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType onPage:1]];
    }
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
#if 0
            FilesTableController *filesTable = [[FilesTableController alloc] init];
            filesTable.projectID = project.projectId;
            filesTable.filesArray = [[NSMutableArray alloc] initWithCapacity:20];
            filesTable.currentPath = @"";
            [filesTable.filesArray addObjectsFromArray:[Project getProjectTreeWithID:project.projectId Branch:nil Path:nil]];
            if (self.personal) {
                [self.navigationController pushViewController:filesTable animated:YES];
            } else {
                [self.parentViewController.navigationController pushViewController:filesTable animated:YES];
            }
#else
            ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] init];
            projectDetails.project = project;
            if (self.personal) {
                [self.navigationController pushViewController:projectDetails animated:YES];
            } else {
                [self.parentViewController.navigationController pushViewController:projectDetails animated:YES];
            }
#endif
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
        if (_personal && [projectsArray count]%20 == 0) {
            NSArray *nextPageProjects = [Project getOwnProjectsOnPage:projectsArray.count/20+1];
            if (nextPageProjects) {
                [projectsArray addObjectsFromArray:nextPageProjects];
            }
            reload = YES;
        } else if (!_personal){
            [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType onPage:self.projectsArray.count/20 + 1]];
            reload = YES;
        }
        if (reload) {[self.tableView reloadData];}
	}
}


#pragma mark - 加载更多

#if 0
- (void)refreshView
{
    NSLog(@"refreshed");
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"更新数据中..."];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, h:mm a"];
    NSString *lastUpdated = [NSString stringWithFormat:@"上次更新日期 %@",
                             [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    //[self.projectsArray removeAllObjects];
    [self.projectsArray addObjectsFromArray:[Project loadPopularProjectOnPage:self.projectsArray.count/20 + 1]];
    NSLog(@"%i", self.projectsArray.count);
    
    [self.tableView reloadData];
}
#endif

- (void)reloadType:(int)newArrangeType
{
    self.arrangeType = newArrangeType;
    [self.projectsArray removeAllObjects];
    
    [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType onPage:1]];
    [self.tableView reloadData];
}

@end
