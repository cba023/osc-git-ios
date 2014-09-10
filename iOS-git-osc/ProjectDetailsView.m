//
//  ProjectDetailsView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectDetailsView.h"
#import "ProjectsTableController.h"
#import "FilesTableController.h"
#import "Tools.h"
#import "Project.h"
#import "GLGitlab.h"
#import "UserDetailsView.h"
#import "IssuesView.h"
#import "ReadmeView.h"
#import "ProjectDescriptionCell.h"
#import "ProjectBasicInfoCell.h"
#import "ProjectNameCell.h"
#import "UIView+Toast.h"
#import "LoginViewController.h"


static NSString * const ProjectDetailsCellID = @"ProjectDetailsCell";
//static NSString * const ProjcetDescriptionCellID = @"ProjcetDescriptionCell";

@interface ProjectDetailsView ()

@property int64_t projectID;

@end

@implementation ProjectDetailsView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    [self initSubviews];
    [self setAutoLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view makeToastActivity];
    NSString *privateToken = [Tools getPrivateToken];
        
    [[GLGitlabApi sharedInstance] getProjectWithId:_projectID
                                      privateToken:privateToken
                                           success:^(id responseObject) {
                                               if (responseObject == nil) {
                                                   [Tools toastNotification:@"网络错误" inView:self.view];
                                               } else {
                                                   _project = responseObject;
                                                   self.title = _project.name;
                                                   [self.view hideToastActivity];
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [_projectInfo reloadData];
                                                   });
                                               }
                                           }

                                           failure:^(NSError *error) {
                                               [self.view hideToastActivity];
                                               [Tools toastNotification:@"网络错误" inView:self.view];
                                           }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithProjectID:(int64_t)projectID;
{
    self = [super init];
    if (self) {
        _projectID = projectID;
    }
    
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!_project) {
        return 0;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 4;
        case 1:
            return 3;       //return 4;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                ProjectNameCell *cell = [[ProjectNameCell alloc] initWithProject:_project];
                return cell;
            }
                
            case 1: {
                ProjectDescriptionCell *cell = [[ProjectDescriptionCell alloc] initWithStarsCount:_project.starsCount
                                                                                     watchesCount:_project.watchesCount
                                                                                        isStarred:_project.isStarred
                                                                                        isWatched:_project.isWatched
                                                                                      description:_project.projectDescription];
                
                [cell.starButton addTarget:self action:@selector(starButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                [cell.watchButton addTarget:self action:@selector(watchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
            case 2: {
                ProjectBasicInfoCell *cell = [[ProjectBasicInfoCell alloc] initWithCreatedTime:_project.createdAt
                                                                                    forksCount:_project.forksCount
                                                                                      isPublic:_project.isPublicProject
                                                                                      language:_project.language];
                
                return cell;
            }
            case 3: {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProjectDetailsCellID forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                NSDictionary *nameAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
                NSMutableAttributedString *ownerAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"拥有者 "
                                                                                                 attributes:nameAttributes];
                [ownerAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:_project.owner.name]];
                UILabel *owner = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                [owner setAttributedText:ownerAttrTxt];
                [cell addSubview:owner];
                
                return cell;
            }
                
            default:
                return nil;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProjectDetailsCellID forIndexPath:indexPath];
        
        for (UIView *view in [cell.contentView subviews]) {
            [view removeFromSuperview];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSArray *rowTitle = @[@"Readme", @"代码", @"问题"];             //@"提交"
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
        [title setText:rowTitle[indexPath.row]];
        [cell.contentView addSubview:title];
        
        return cell;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section, row = indexPath.row;
    
    if (section == 0 && row == 0) {
        return 75;
    } else if (section == 0 && row == 1) {
        UILabel *tmpLabel = [UILabel new];
        tmpLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tmpLabel.numberOfLines = 0;
        tmpLabel.font = [UIFont systemFontOfSize:15];
        tmpLabel.text = _project.projectDescription.length > 0? _project.projectDescription : @"暂无项目介绍";
        
        CGSize size = [tmpLabel sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        return size.height + 61;
    } else if (section == 0 && row == 2) {
        return 80;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger section = indexPath.section, row = indexPath.row;

    if (section == 0 && row == 3) {
        UserDetailsView *userDetails = [[UserDetailsView alloc] initWithUser:_project.owner];
        [self.navigationController pushViewController:userDetails animated:YES];
    } else if (section == 1) {
        switch (row) {
            case 0: {
                ReadmeView *readme = [[ReadmeView alloc] initWithProjectID:_project.projectId];
                [self.navigationController pushViewController:readme animated:YES];
                break;
            }
            case 1: {
                FilesTableController *filesTable = [[FilesTableController alloc] initWithProjectID:_project.projectId
                                                                                       projectName:_project.name
                                                                                         ownerName:_project.owner.username];
                filesTable.currentPath = @"";
                filesTable.filesArray = [[NSMutableArray alloc] initWithArray:[Project getProjectTreeWithID:_project.projectId
                                                                                                     Branch:nil
                                                                                                       Path:nil]];
                [self.navigationController pushViewController:filesTable animated:YES];
                break;
            }
            case 2: {
                IssuesView *issuesView = [[IssuesView alloc] initWithProjectId:_project.projectId];
                [self.navigationController pushViewController:issuesView animated:YES];
                break;
            }
            default:
                break;
        }
    }
}


#pragma mark - About Subviews and Layout

- (void)initSubviews
{
    _projectInfo = [UITableView new];
    [_projectInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:ProjectDetailsCellID];
    _projectInfo.dataSource = self;
    _projectInfo.delegate = self;
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    _projectInfo.tableFooterView = footer;
    
    [self.view addSubview:_projectInfo];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_projectInfo);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_projectInfo]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_projectInfo]|" options:0 metrics:nil views:viewDictionary]];
}

- (void)starButtonClicked
{
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"无网络连接" inView:self.view];
    }
    
    NSString *privateToken = [Tools getPrivateToken];
    if (privateToken.length == 0) {
        LoginViewController *loginViewController = [LoginViewController new];
        [self.navigationController pushViewController:loginViewController animated:YES];
        return;
    }
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        _project.starred = !_project.starred;
        _project.starsCount = [responseObject intValue];
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [_projectInfo reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        [Tools toastNotification:@"网络错误" inView:self.view];
    };
    
    if (_project.starred) {
        [[GLGitlabApi sharedInstance] unstarProject:_project.projectId privateToken:privateToken success:success failure:failure];
    } else {
        [[GLGitlabApi sharedInstance] starProject:_project.projectId privateToken:privateToken success:success failure:failure];
    }}

- (void)watchButtonClicked
{
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"无网络连接" inView:self.view];
    }

    NSString *privateToken = [Tools getPrivateToken];
    if (privateToken.length == 0) {
        LoginViewController *loginViewController = [LoginViewController new];
        [self.navigationController pushViewController:loginViewController animated:YES];
        return;
    }
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        _project.watched = !_project.watched;
        _project.watchesCount = [responseObject intValue];
        NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
        [_projectInfo reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        [Tools toastNotification:@"网络错误" inView:self.view];
    };
    
    if (_project.watched) {
        [[GLGitlabApi sharedInstance] unwatchProject:_project.projectId privateToken:privateToken success:success failure:failure];
    } else {
        [[GLGitlabApi sharedInstance] watchProject:_project.projectId privateToken:privateToken success:success failure:failure];
    }
}


@end
