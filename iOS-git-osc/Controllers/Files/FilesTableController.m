//
//  FilesTableController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLGitlab.h"
#import "FilesTableController.h"
#import "FileCell.h"
#import "FileContentView.h"
#import "File.h"
#import "ImageView.h"
#import "Tools.h"
#import "UIView+Toast.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "DataSetObject.h"

@interface FilesTableController ()

@property (nonatomic, strong) NSMutableArray *filesArray;
@property (nonatomic, strong) DataSetObject *emptyDataSet;

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
    
    /* 设置空页面状态 */
    [self fetchForFiles];
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    __weak FilesTableController *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchForFiles];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchForFiles
{
    if (_filesArray.count > 0) {return;}
    
    self.emptyDataSet.state = loadingState;
    
    AFHTTPRequestOperationManager  *manager = [AFHTTPRequestOperationManager GitManager];
    NSDictionary *parameters = @{
                                 @"private_token" : _privateToken,
                                 @"ref_name"      : @"master",
                                 @"path"          : _currentPath
                                 };
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/tree", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace];
    
    [manager GET:strUrl
      parameters:parameters
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (responseObject == nil){ } else {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLFile *file = [[GLFile alloc] initWithJSON:obj];
                     [_filesArray addObject:file];
                 }];
             }
             
             if (_filesArray.count == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有相关文件";
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             self.emptyDataSet.state = netWorkingErrorState;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
    }];
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
    
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = UIColorFromRGB(0xdadbdc);
    [cell setSelectedBackgroundView:selectedBackground];
    
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
        innerFilesTable.projectNameSpace = _projectNameSpace;
        innerFilesTable.privateToken = self.privateToken;
        
        [self.navigationController pushViewController:innerFilesTable animated:YES];
    } else {
        [self openFile:file];
    }
}

#pragma mark - 打开文件

- (void)openFile:(GLFile *)file
{
    if ([File isCodeFile:file.name]) {
        FileContentView *fileContentView = [[FileContentView alloc] initWithProjectID:_projectID path:_currentPath fileName:file.name projectNameSpace:_projectNameSpace];
        
        [self.navigationController pushViewController:fileContentView animated:YES];
    } else if ([File isImage:file.name]) {
        NSString *imageURL = [NSString stringWithFormat:@"https://git.oschina.net/%@/%@/raw/master/%@/%@?private_token=%@", _ownerName, _projectName, _currentPath, file.name, [Tools getPrivateToken]];
        ImageView *imageView = [[ImageView alloc] initWithImageURL:imageURL];
        imageView.title = file.name;
        
        [self.navigationController pushViewController:imageView animated:YES];
    } else {
        NSString *urlString = [NSString stringWithFormat:@"https://git.oschina.net/%@/%@/blob/master/%@%@?private_token=%@", _ownerName, _projectName, _currentPath, file.name, [Tools getPrivateToken]];
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
}



@end
