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

static NSString * const ProjectDetailsCellID = @"ProjectDetailsCell";
//static NSString * const ProjcetDescriptionCellID = @"ProjcetDescriptionCell";

@interface ProjectDetailsView ()

@end

@implementation ProjectDetailsView

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
    
    self.navigationController.navigationBar.translucent = NO;
    self.title = _project.name;
    
    [self initSubviews];
    [self setAutoLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_project.parentId) {
        _parentProject = [Project getASingleProject:_project.parentId];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithProject:(GLProject *)project
{
    self = [super init];
    if (self) {
        _project = project;
    }
    return self;
}

- (id)initWithProjectId:(int64_t)projectId
{
    self = [super init];
    if (self) {
        _project = [Project getASingleProject:projectId];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
        case 1:
            return 3;       //return 4;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 0
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
#endif
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                ProjectDescriptionCell *cell = [[ProjectDescriptionCell alloc] initWithStarsCount:_project.starsCount
                                                                                     watchesCount:_project.watchesCount
                                                                                        isStarred:NO
                                                                                        isWatched:NO
                                                                                      description:_project.projectDescription];
                return cell;
            }
            case 1: {
                ProjectBasicInfoCell *cell = [[ProjectBasicInfoCell alloc] initWithCreatedTime:_project.createdAt
                                                                                    forksCount:_project.forksCount
                                                                                      isPublic:_project.isPublicProject
                                                                                      language:_project.language];
                
                return cell;
            }
            case 2: {
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
        UILabel *tmpLabel = [UILabel new];
        tmpLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tmpLabel.numberOfLines = 0;
        tmpLabel.font = [UIFont systemFontOfSize:15];
        tmpLabel.text = _project.projectDescription;
        
        CGSize size = [tmpLabel sizeThatFits:CGSizeMake(tableView.frame.size.width - 16, MAXFLOAT)];
        return size.height + 59;
    } else if (section == 0 && row == 1) {
        return 80;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: {
                UserDetailsView *userDetails = [[UserDetailsView alloc] initWithUser:_project.owner];
                [self.navigationController pushViewController:userDetails animated:YES];
                break;
            }
            case 1: {
                if (_parentProject) {
                    ProjectDetailsView *parentProjectDetails = [[ProjectDetailsView alloc] initWithProject:_parentProject];
                    [self.navigationController pushViewController:parentProjectDetails animated:YES];
                }
                break;
            }
            case 2: {
                if (_parentProject) {break;}
                else {
                    ReadmeView *readme = [[ReadmeView alloc] initWithProjectID:_project.projectId];
                    [self.navigationController pushViewController:readme animated:NO];
                }
                break;
            }
            case 3: {
                ReadmeView *readme = [[ReadmeView alloc] initWithProjectID:_project.projectId];
                [self.navigationController pushViewController:readme animated:NO];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                
                break;
            case 1: {
                IssuesView *issuesView = [[IssuesView alloc] initWithProjectId:_project.projectId];
                [self.navigationController pushViewController:issuesView animated:YES];
                break;
            }
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        FilesTableController *filesTable = [FilesTableController new];
        filesTable.projectID = _project.projectId;
        filesTable.currentPath = @"";
        filesTable.filesArray = [[NSMutableArray alloc] initWithArray:[Project getProjectTreeWithID:_project.projectId
                                                                                             Branch:nil
                                                                                               Path:nil]];
        [self.navigationController pushViewController:filesTable animated:YES];
    }
}


#pragma mark - About Subviews and Layout

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [Tools setPortraitForUser:_project.owner view:_portrait cornerRadius:5.0];
    UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(tapPortrait:)];
    _portrait.userInteractionEnabled = YES;
    [_portrait addGestureRecognizer:tapPortraitRecognizer];
    [self.view addSubview:_portrait];
    
    _projectName = [UILabel new];
    [_projectName setText:_project.name];
    [self.view addSubview:_projectName];
    
    _timeInterval = [UILabel new];
    NSDictionary *grayTextAttributes = @{
                                         NSForegroundColorAttributeName:[UIColor grayColor],
                                         NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:15]
                                         };
    NSMutableAttributedString *updateTime = [[NSMutableAttributedString alloc] initWithString:@"更新于 " attributes:grayTextAttributes];
    [updateTime appendAttributedString:[Tools getIntervalAttrStr:_project.lastPushAt]];
    [_timeInterval setAttributedText:updateTime];
    [self.view addSubview:_timeInterval];
    
    _projectInfo = [UITableView new];
    [_projectInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:ProjectDetailsCellID];
    //[_projectInfo registerClass:[ProjectDescriptionCell class] forCellReuseIdentifier:ProjcetDescriptionCellID];
    _projectInfo.dataSource = self;
    _projectInfo.delegate = self;
    _projectInfo.bounces = NO;
    _projectInfo.scrollEnabled = NO;
    [self.view addSubview:_projectInfo];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[_portrait(36)]-[_timeInterval][_projectInfo]-(8)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_portrait, _timeInterval, _projectInfo)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[_portrait(36)]-[_projectName]-(>=8)-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _projectName)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_projectInfo]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_projectInfo)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait]-[_timeInterval]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _timeInterval)]];
}

#pragma mark - recognizer
- (void)tapPortrait:(UITapGestureRecognizer *)sender
{
    UserDetailsView *userDetails = [UserDetailsView new];
    userDetails.user = _project.owner;
    [self.navigationController pushViewController:userDetails animated:YES];
}


@end
