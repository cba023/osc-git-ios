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

static NSString * const ProjectDetailsCellId = @"ProjectDetailsCell";

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
    
    if (_project.parentId) {
        _parentProject = [Project getASingleProject:_project.parentId];
    }
    
    if (_project.projectDescription.length == 0) {
        //_project.projectDescription = @"暂无介绍";
        _haveADescription = YES;
    }
    
    [self initSubviews];
    [self setAutoLayout];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: {
            int sectionsCount = 3;
            if (_project.parentId) {sectionsCount++;}
            return sectionsCount;
        }
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"项目信息";
        case 1:
            return @"项目情况";
        case 2:
            return @"代码";
        default:
            return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ProjectDetailsCellId forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    for (UIView *view in [cell.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    if (indexPath.section == 0) {
        [self generateTabelCell:cell inRow:indexPath.row];
    } else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0: {
                UILabel *members = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                [members setText:@"成员"];
                [cell.contentView addSubview:members];
                break;
            }
            case 1: {
                UILabel *issues = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                [issues setText:@"问题"];
                [cell.contentView addSubview:issues];
                break;
            }
            default:
                break;
        }
    } else {
        UILabel *code = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
        [code setText:_project.defaultBranch];
        [cell.contentView addSubview:code];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section, row = indexPath.row;
    if (section == 0) {
        if ((row == 1 && !_parentProject) || (row == 2 && _parentProject)) {
            UITextView *titleView = [UITextView new];
            titleView.text = _project.projectDescription;
            titleView.font = [UIFont boldSystemFontOfSize:14];
            
            CGSize size = [titleView sizeThatFits:CGSizeMake(tableView.frame.size.width - 60, MAXFLOAT)];
            
            return size.height + 20;
        }
    }
    return 40;
}

#if 0
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
}
#endif

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
                    [self.navigationController pushViewController:readme animated:YES];
                }
                break;
            }
            case 3: {
                ReadmeView *readme = [[ReadmeView alloc] initWithProjectID:_project.projectId];
                [self.navigationController pushViewController:readme animated:YES];
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

#pragma mark - generate table cell

- (void)generateTabelCell:(UITableViewCell *)cell inRow:(NSInteger)row
{
    NSDictionary *nameAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
    
    UILabel *content = [UILabel new];
    [cell.contentView addSubview:content];
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[content]-5-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(content)]];
    
    [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[content]-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(content)]];
    
    switch (row) {
        case 0: {
            NSMutableAttributedString *ownerAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"拥有者 " attributes:nameAttributes];
            [ownerAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:_project.owner.name]];
            [content setAttributedText:ownerAttrTxt];
            break;
        }
        case 1: {
            if (_parentProject) {
                NSMutableAttributedString *forkFromAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"fork from "
                                                                                                    attributes:nameAttributes];
                [forkFromAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", _parentProject.owner.name, _parentProject.name]]];
                [content setAttributedText:forkFromAttrTxt];
            } else {
                content.lineBreakMode = NSLineBreakByCharWrapping;
                content.numberOfLines = 0;
                [content setText:_project.projectDescription];
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        }
        case 2: {
            if (_project.projectDescription && _parentProject) {
                [content setText:_project.projectDescription];
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                [content setText:@"README"];
                [cell.contentView addSubview:content];
            }
            break;
        }
        case 3: {
            [content setText:@"README"];
            break;
        }
        default:
            break;
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
    NSDictionary *grayTextAttributes = @{NSForegroundColorAttributeName:[UIColor grayColor]};
    NSMutableAttributedString *updateTime = [[NSMutableAttributedString alloc] initWithString:@"更新于" attributes:grayTextAttributes];
    [updateTime appendAttributedString:[Tools getIntervalAttrStr:_project.lastPushAt]];
    [_timeInterval setAttributedText:updateTime];
    [self.view addSubview:_timeInterval];
    
    _language = [UILabel new];
    [_language setText:_project.language?_project.language: @"Unknown"];
    [self.view addSubview:_language];
    
    _starButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_starButton setImage:[UIImage imageNamed:@"star2"] forState:UIControlStateNormal];
    _starButton.tintColor = [UIColor blackColor];
    //[Tools roundCorner:_starButton];
    //[_starButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_starButton setTitle:[NSString stringWithFormat:@"%i", _project.starsCount] forState:UIControlStateNormal];
    //[starButton setImage:[UIImage imageNamed:@"star2"] forState:UIControlStateSelected];
    //[starButton setTitle:[NSString stringWithFormat:@"%i stars", _project.starsCount+1] forState:UIControlStateSelected];
    [self.view addSubview:_starButton];
    
    _forkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_forkButton setImage:[UIImage imageNamed:@"fork"] forState:UIControlStateNormal];
    _forkButton.tintColor = [UIColor blackColor];
    //[Tools roundCorner:_forkButton];
    [_forkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_forkButton setTitle:[NSString stringWithFormat:@"%i", _project.forksCount] forState:UIControlStateNormal];
    [self.view addSubview:_forkButton];
    
    _projectInfo = [UITableView new];
    [_projectInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:ProjectDetailsCellId];
    _projectInfo.dataSource = self;
    _projectInfo.delegate = self;
    [self.view addSubview:_projectInfo];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[_portrait(36)]-[_timeInterval]-(8)-[_starButton]-(8)-[_projectInfo]-(8)-|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_portrait, _timeInterval, _starButton, _projectInfo)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[_portrait(36)]-[_projectName]-(>=8)-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _projectName)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[_language]-(15)-[_starButton(_forkButton)]-(15)-[_forkButton(>=30)]"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_language, _starButton, _forkButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_projectInfo]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_projectInfo)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait]-[_timeInterval]-[_language]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _timeInterval, _language)]];
}

#pragma mark - recognizer
- (void)tapPortrait:(UITapGestureRecognizer *)sender
{
    UserDetailsView *userDetails = [UserDetailsView new];
    userDetails.user = _project.owner;
    [self.navigationController pushViewController:userDetails animated:YES];
}


@end
