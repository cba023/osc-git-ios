//
//  FilesTableController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLGitlab.h"
#import "FilesTableController.h"
#import "Project.h"
#import "FileCell.h"
#import "FileContentView.h"
#import "File.h"
#import "ImageView.h"
#import "Tools.h"
#import "UIView+Toast.h"

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

- (id)initWithProjectID:(int64_t)projectID projectName:(NSString *)projectName ownerName:(NSString *)ownerName
{
    self = [super init];
    if (self) {
        _projectID = projectID;
        _projectName = projectName;
        _ownerName = ownerName;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FileCell class] forCellReuseIdentifier:cellId];
    self.tableView.backgroundColor = [Tools uniformColor];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    _filesArray = [NSMutableArray new];
    
#if 0
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"松手更新数据"]];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    //[self setRefreshControl:self.refreshControl];
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_filesArray.count > 0) {return;}
    
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    }
    
    [self.view makeToastActivity];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        [self.view hideToastActivity];
        if (responseObject == nil){
            [Tools toastNotification:@"请求失败，请稍后再试" inView:self.view];
        } else {
            [_filesArray addObjectsFromArray:responseObject];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        [self.view hideToastActivity];
        [Tools toastNotification:[error description] inView:self.view];
    };
    
    [[GLGitlabApi sharedInstance] getRepositoryTreeForProjectId:_projectID
                                                   privateToken:_privateToken
                                                           path:_currentPath
                                                     branchName:@"master"
                                                   successBlock:success
                                                   failureBlock:failure];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
        FilesTableController *innerFilesTable = [[FilesTableController alloc] initWithProjectID:_projectID
                                                                                    projectName:_projectName
                                                                                      ownerName:_ownerName];
        innerFilesTable.title = file.name;
        innerFilesTable.currentPath = [NSString stringWithFormat:@"%@%@/", self.currentPath, file.name];
        innerFilesTable.privateToken = self.privateToken;
        
        [self.navigationController pushViewController:innerFilesTable animated:YES];
    } else {
        [self openFile:file];
    }
}

- (void)openFile:(GLFile *)file
{
    if ([File isCodeFile:file.name]) {
        FileContentView *fileContentView = [[FileContentView alloc] initWithProjectID:_projectID path:_currentPath fileName:file.name];
        
        [self.navigationController pushViewController:fileContentView animated:YES];
    } else if ([File isImage:file.name]) {
        NSString *imageURL = [NSString stringWithFormat:@"https://git.oschina.net/%@/%@/raw/master/%@/%@?private_token=%@", _ownerName, _projectName, _currentPath, file.name, [Tools getPrivateToken]];
        ImageView *imageView = [[ImageView alloc] initWithImageURL:imageURL];
        imageView.title = file.name;
        
        [self.navigationController pushViewController:imageView animated:YES];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"https://git.oschina.net/%@/%@/blob/master/%@/%@?private_token=%@", _ownerName, _projectName, _currentPath, file.name, [Tools getPrivateToken]];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}



@end
