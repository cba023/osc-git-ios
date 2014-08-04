//
//  ProjectDetailsView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectDetailsView.h"
#import "ProjectsTableController.h"
#import "Tools.h"
#import "Project.h"
#import "GLGitlab.h"

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
    
    if (_project.parentId) {
        _parentProject = [Project getASingleProject:_project.parentId];
    }
    
    [self initSubviews];
    [self setAutoLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            int sectionsCount = 2;
            if (_project.parentId) {sectionsCount++;}
            if (_project.projectDescription && ![_project.projectDescription isEqualToString:@""]) {sectionsCount++;}
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

- (GLfloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (GLfloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            case 0:
                

                break;
                
            default:
                break;
        }
    }
}

- (void)generateTabelCell:(UITableViewCell *)cell inRow:(NSInteger)row
{
    NSDictionary *nameAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
    
    switch (row) {
        case 0: {
            UILabel *owner = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
            NSMutableAttributedString *ownerAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"拥有者 " attributes:nameAttributes];
            [ownerAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:_project.owner.name]];
            [owner setAttributedText:ownerAttrTxt];
            [cell.contentView addSubview:owner];
            break;
        }
        case 1: {
            if (_parentProject) {
                UILabel *forkFrom = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                NSMutableAttributedString *forkFromAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"fork from "
                                                                                                    attributes:nameAttributes];
                [forkFromAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", _parentProject.owner.name, _parentProject.name]]];
                [forkFrom setAttributedText:forkFromAttrTxt];
                [cell.contentView addSubview:forkFrom];
            } else if (_project.projectDescription && ![_project.projectDescription isEqualToString:@""]) {
                UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                [description setText:_project.projectDescription];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.contentView addSubview:description];
            } else {
                UILabel *readme = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                [readme setText:@"README"];
                [cell.contentView addSubview:readme];
            }
            break;
        }
        case 2: {
            if (_project.projectDescription && _parentProject) {
                UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                [description setText:_project.projectDescription];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [cell.contentView addSubview:description];
            } else {
                UILabel *readme = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
                [readme setText:@"README"];
                [cell.contentView addSubview:readme];
            }
            break;
        }
        case 3: {
            UILabel *readme = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
            [readme setText:@"README"];
            [cell.contentView addSubview:readme];
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
    [_language setText:_project.language?_project.language: @""];
    [self.view addSubview:_language];
    
    _starButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_starButton setImage:[UIImage imageNamed:@"star2"] forState:UIControlStateNormal];
    //[_starButton setBackgroundColor:UIColorFromRGB(0x00FFFF)];
    _starButton.tintColor = [UIColor blackColor];
    //[Tools roundCorner:_starButton];
    //[_starButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_starButton setTitle:[NSString stringWithFormat:@"%i stars", _project.starsCount] forState:UIControlStateNormal];
    //[starButton setImage:[UIImage imageNamed:@"star2"] forState:UIControlStateSelected];
    //[starButton setTitle:[NSString stringWithFormat:@"%i stars", _project.starsCount+1] forState:UIControlStateSelected];
    [self.view addSubview:_starButton];
    
    _forkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_forkButton setImage:[UIImage imageNamed:@"fork"] forState:UIControlStateNormal];
    //[_forkButton setBackgroundColor:UIColorFromRGB(0x00FFFF)];
    _forkButton.tintColor = [UIColor blackColor];
    //[Tools roundCorner:_forkButton];
    [_forkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_forkButton setTitle:[NSString stringWithFormat:@"%i forks", _project.forksCount] forState:UIControlStateNormal];
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
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"|-(8)-[_language]-(%d)-[_starButton(_forkButton)]-(15)-[_forkButton(>=30)]", _project.language? 15: 0]
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


@end
