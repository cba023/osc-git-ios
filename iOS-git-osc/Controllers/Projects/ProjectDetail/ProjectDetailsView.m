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
#import "GLGitlab.h"
#import "IssuesView.h"
#import "ReadmeView.h"
#import "ProjectDescriptionCell.h"
#import "ProjectBasicInfoCell.h"
#import "ProjectNameCell.h"
#import "UIView+Toast.h"
#import "LoginViewController.h"
#import "UMSocial.h"
#import "TitleScrollViewController.h"
#import "ProjectsCommitsViewController.h"
#import "EventsView.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "DataSetObject.h"

static NSString * const ProjectDetailsCellID = @"ProjectDetailsCell";
//static NSString * const ProjcetDescriptionCellID = @"ProjcetDescriptionCell";

@interface ProjectDetailsView () <UIActionSheetDelegate>

@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *namsSpace;
@property (nonatomic, copy) NSString *projectName;

@property (nonatomic, copy) NSString *projectURL;
@property (nonatomic, copy) NSString *privateToken;

@property (nonatomic, strong) DataSetObject *emptyDataSet;

@end

@implementation ProjectDetailsView

- (id)initWithProjectID:(int64_t)projectID projectNameSpace:(NSString *)nameSpace
{
    self = [super init];
    if (self) {
        _projectID = projectID;
        _namsSpace = nameSpace;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    [[UITableViewHeaderFooterView appearance] setTintColor:UIColorFromRGB(0xf0f0f0)];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ProjectDetailsCellID];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    
    /* 设置空页面状态 */
    [self fetchProjectsDetail];
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.tableView];
    __weak ProjectDetailsView *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchProjectsDetail];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据

- (void)fetchProjectsDetail
{
    self.emptyDataSet.state = loadingState;
    
    if (_project) {return;}
    
    _user = [NSUserDefaults standardUserDefaults];
    _privateToken = [_user objectForKey:@"private_token"];
    
    //NSString *strUrl = _privateToken.length ? [NSString stringWithFormat:@"%@%@/%@?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _namsSpace, _privateToken] : [NSString stringWithFormat:@"%@%@/%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _namsSpace];
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectId = [NSString stringWithFormat:@"%lld",_projectID];
    
    NSString *strUrl = _privateToken.length ? [NSString stringWithFormat:@"%@%@/%@?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, projectId, _privateToken] : [NSString stringWithFormat:@"%@%@/%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, projectId];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if (responseObject == nil) { } else {
                 _project = [[GLProject alloc] initWithJSON:responseObject];
                 self.title = _project.name;
                 NSString *httpStr = [GITAPI_HTTPS_PREFIX componentsSeparatedByString:@"/api/v3/"][0];
                 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                           initWithImage:[UIImage imageNamed:@"projectDetails_more"]
                                                           style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(moreChoice)];
                 
                 _projectURL = [NSString stringWithFormat:@"%@/%@/%@", httpStr, _project.owner.username, _project.path];
                 
             }
             
             if (_project.name.length == 0) {
                 self.emptyDataSet.state = noDataState;
                 self.emptyDataSet.respondString = @"还没有相关项目详情";
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

#pragma mark - tableview things

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
            return 3;
        case 1:
            return 5;       //return 4;
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
                
                [cell.starButton addTarget:self action:@selector(clickedStarOrUnstar) forControlEvents:UIControlEventTouchUpInside];
                [cell.watchButton addTarget:self action:@selector(clickedWatchOrUnwatch) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
            case 2: {
                ProjectBasicInfoCell *cell = [[ProjectBasicInfoCell alloc] initWithCreatedTime:_project.createdAt
                                                                                    forksCount:_project.forksCount
                                                                                      isPublic:_project.isPublicProject
                                                                                      language:_project.language];
                
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
        
        if (indexPath.row == 0) {
            NSDictionary *nameAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
            NSMutableAttributedString *ownerAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"拥有者 "
                                                                                             attributes:nameAttributes];
            [ownerAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:_project.owner.name]];
            [cell.textLabel setAttributedText:ownerAttrTxt];
            
            [cell.imageView setImage:[UIImage imageNamed:@"projectDetails_owner"]];
            
            return cell;
        }
        NSArray *rowTitle = @[@"Readme", @"代码", @"问题", @"提交"];             //@"提交"
        [cell.textLabel setText:rowTitle[indexPath.row - 1]];
        
        NSArray *imageName = @[@"projectDetails_readme", @"projectDetails_code", @"projectDetails_issue", @"projectDetails_branch"];
        [cell.imageView setImage:[UIImage imageNamed:imageName[indexPath.row - 1]]];
        
        return cell;
    }
}

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
        return size.height + 61 + 34;
    } else if (section == 0 && row == 2) {
        return 80;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSUInteger section = indexPath.section, row = indexPath.row;
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];

    if (section == 1) {
        switch (row) {
            case 0: {
                TitleScrollViewController *ownDetailsView = [[TitleScrollViewController alloc] initWithTitle:_project.owner.name
                                                                                                andSubTitles:@[@"动态", @"项目", @"Star", @"Watch"]
                                                                                           andSubControllers:@[
                                                                                                               [[EventsView alloc] initWithUserID:_project.owner.userId],
                                                                                                               [[ProjectsTableController alloc] initWithUserID:_project.owner.userId andProjectsType:ProjectsTypeUserProjects],
                                                                                                               [[ProjectsTableController alloc] initWithUserID:_project.owner.userId andProjectsType:ProjectsTypeStared],
                                                                                                               [[ProjectsTableController alloc] initWithUserID:_project.owner.userId andProjectsType:ProjectsTypeWatched]
                                                                                                               ]
                                                                                              andUnderTabbar:NO
                                                                                             andUserPortrait:NO];
                
                [self.navigationController pushViewController:ownDetailsView animated:YES];
                break;
            }
            case 1: {
                ReadmeView *readme = [[ReadmeView alloc] initWithProjectID:_project.projectId projectNameSpace:_project.nameSpace];
                [self.navigationController pushViewController:readme animated:YES];
                break;
            }
            case 2: {
                FilesTableController *filesTable = [[FilesTableController alloc] initWithProjectID:_project.projectId
                                                                                       projectName:_project.name
                                                                                         ownerName:_project.owner.username];
                filesTable.title = _project.name;
                filesTable.currentPath = @"";
                filesTable.projectNameSpace = _project.nameSpace;
                filesTable.privateToken = [Tools getPrivateToken];
                
                [self.navigationController pushViewController:filesTable animated:YES];
                break;
            }
            case 3: {
                IssuesView *issuesView = [[IssuesView alloc] initWithProjectId:_project.projectId projectNameSpace:_project.nameSpace];
                [self.navigationController pushViewController:issuesView animated:YES];
                break;
            }
            case 4: {
                ProjectsCommitsViewController *commitController = [[ProjectsCommitsViewController alloc] initWithProjectID:_project.projectId projectNameSpace:_project.nameSpace];
                [self.navigationController pushViewController:commitController animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - star or unstar
- (void)clickedStarOrUnstar
{
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
    }
    
    NSString *privateToken = [Tools getPrivateToken];
    if (privateToken.length == 0) {
        LoginViewController *loginViewController = [LoginViewController new];
        [self.navigationController pushViewController:loginViewController animated:YES];
        return;
    }
    
    NSString *strUrl = _project.starred ? [NSString stringWithFormat:@"%@%@/%@/unstar?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _namsSpace, [Tools getPrivateToken]] :
    [NSString stringWithFormat:@"%@%@/%@/star?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _namsSpace, [Tools getPrivateToken]];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    [manager POST:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             _project.starred = !_project.starred;
             _project.starsCount = [[responseObject objectForKey:@"count"] intValue];
             NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
             [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             
             if (error != nil) {
                 [Tools toastNotification:[NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code] inView:self.view];
             } else {
                 [Tools toastNotification:@"网络错误" inView:self.view];
             }
         }];
}

#pragma mark - watch or unwatch

- (void)clickedWatchOrUnwatch
{
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
    }
    
    NSString *privateToken = [Tools getPrivateToken];
    if (privateToken.length == 0) {
        LoginViewController *loginViewController = [LoginViewController new];
        [self.navigationController pushViewController:loginViewController animated:YES];
        return;
    }
    
    NSString *strUrl = _project.watched ? [NSString stringWithFormat:@"%@%@/%@/unwatch?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _namsSpace, [Tools getPrivateToken]] :
    [NSString stringWithFormat:@"%@%@/%@/watch?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _namsSpace, [Tools getPrivateToken]];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    [manager POST:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             _project.watched = !_project.watched;
             _project.watchesCount = [[responseObject objectForKey:@"count"] intValue];
             NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
             [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             
             if (error != nil) {
                 [Tools toastNotification:[NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code] inView:self.view];
             } else {
                 [Tools toastNotification:@"网络错误" inView:self.view];
             }
         }];
}

#pragma mark - 导航栏右侧按键

- (void)moreChoice
{
    [[[UIActionSheet alloc] initWithTitle:nil
                                 delegate:self
                        cancelButtonTitle:NSLocalizedString(@"取消", nil)
                   destructiveButtonTitle:nil
                        otherButtonTitles:NSLocalizedString(@"分享项目", nil), NSLocalizedString(@"复制链接", nil),NSLocalizedString(@"在浏览器中打开", nil), nil]
     
     showInView:self.view];
}

- (void)showShareView
{
    // 微信相关设置
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = _projectURL;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _projectURL;
    //[UMSocialData defaultData].extConfig.wechatFavoriteData.url = _projectURL;
    [UMSocialData defaultData].extConfig.title = _project.name;
    
    // 手机QQ相关设置
    
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = _project.name;
    [UMSocialData defaultData].extConfig.qqData.url = _projectURL;
    
    // 新浪微博相关设置
    
    [[UMSocialData defaultData].extConfig.sinaData.urlResource setResourceType:UMSocialUrlResourceTypeDefault url:_projectURL];
    
    // 显示分享的平台icon
    NSLog(@"网址:%@", _projectURL);
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"5423cd47fd98c58f04000c52"
                                      shareText:[NSString stringWithFormat:@"我在关注%@的项目%@，你也来瞧瞧呗！%@", _project.owner.name, _project.name, _projectURL]
                                     shareImage:[Tools getScreenshot:self.view]
                                shareToSnsNames:@[
                                                  UMShareToWechatSession, UMShareToWechatTimeline, UMShareToQQ, UMShareToSina //, UMShareToWechatFavorite
                                                  ]
                                       delegate:nil];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    } else if (buttonIndex == 0) {
        [self showShareView];
    } else if (buttonIndex == 1) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = _projectURL;
        [Tools toastNotification:@"链接已复制到剪贴板" inView:self.view];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_projectURL]];
    }
}



@end
