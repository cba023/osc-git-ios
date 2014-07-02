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
#import "GLGitlab.h"
#import "Project.h"

@interface ProjectsTableController ()

@end

@implementation ProjectsTableController
@synthesize projectsArray;
//@synthesize loadingMore;

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
    self.title = @"热门项目";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
#if 0
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手更新数据"]];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    //[self setRefreshControl:self.refreshControl];
#endif
    
    self.projectsArray = [[NSMutableArray alloc] initWithCapacity:20];
    [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType OnPage:self.projectsArray.count/20 + 1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.projectsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    ProjectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil) {
        cell = [[ProjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSUInteger rowNo = indexPath.row;
    GLProject *project = [self.projectsArray objectAtIndex:rowNo];
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
    int row = [indexPath row];
    if (row < self.projectsArray.count) {
        GLProject *project = [projectsArray objectAtIndex:row];
        if (project) {
            FilesTableController *filesTable = [[FilesTableController alloc] init];
            filesTable.filesArray = [[NSMutableArray alloc] initWithCapacity:20];
            [filesTable.filesArray addObjectsFromArray:[Project getProjectTreeWithID:project.projectId Branch:nil Path:nil]];
            [self.parentViewController.navigationController pushViewController:filesTable animated:YES];
        }
    }
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
        [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType OnPage:self.projectsArray.count/20 + 1]];
        [self.tableView reloadData];
	}
}

#pragma mark - reload

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
    
    [self.projectsArray addObjectsFromArray:[Project loadExtraProjectType:self.arrangeType OnPage:self.projectsArray.count/20 + 1]];
    [self.tableView reloadData];
}

@end
