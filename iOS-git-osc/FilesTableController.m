//
//  FilesTableController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLGitlab.h"
#import "FilesTableController.h"
#import "NavigationController.h"
#import "Project.h"
#import "FileCell.h"
#import "FileContentView.h"

@interface FilesTableController ()

@end

static NSString * const cellId = @"FileCell";

@implementation FilesTableController

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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(popBack)];
    self.title = @"项目文件";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FileCell class] forCellReuseIdentifier:cellId];
    
#if 0
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手更新数据"]];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    //[self setRefreshControl:self.refreshControl];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    GLFile *file = [self.filesArray objectAtIndex:indexPath.row];
    if (file.type == GLFileTypeTree) {
        [cell.fileType setImage:[UIImage imageNamed:@"folder"]];
    } else {
        [cell.fileType setImage:[UIImage imageNamed:@"file"]];
    }
    cell.fileName.text = file.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GLFile *file = [self.filesArray objectAtIndex:indexPath.row];
    if (file.type == GLFileTypeTree) {
        FilesTableController *innerFilesTable = [[FilesTableController alloc] init];
        innerFilesTable.projectID = self.projectID;
        innerFilesTable.currentPath = [NSString stringWithFormat:@"%@%@/", self.currentPath, file.name];
        innerFilesTable.filesArray = [[NSMutableArray alloc] initWithCapacity:20];
        [innerFilesTable.filesArray addObjectsFromArray:[Project getProjectTreeWithID:innerFilesTable.projectID
                                                                               Branch:@"master"
                                                                                 Path:innerFilesTable.currentPath]];
        
        [self.navigationController pushViewController:innerFilesTable animated:YES];
    } else {
        FileContentView *fileContentView = [[FileContentView alloc] init];
        fileContentView.content = [Project getFileContent:self.projectID
                                                     Path:[NSString stringWithFormat:@"%@%@", self.currentPath, file.name]
                                                   Branch:@"master"];
        fileContentView.fileName = file.name;
        
        [self.navigationController pushViewController:fileContentView animated:YES];
    }
}

@end
