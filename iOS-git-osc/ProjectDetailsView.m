//
//  ProjectDetailsView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-30.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectDetailsView.h"
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
    
    UIImageView *portrait = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 33, 33)];
    portrait.contentMode = UIViewContentModeScaleAspectFit;
    [Tools setPortraitForUser:_project.owner view:portrait];
    [self.view addSubview:portrait];
    
    UILabel *projectName = [[UILabel alloc] initWithFrame:CGRectMake(49, 10, 251, 33)];
    [projectName setText:_project.name];
    [self.view addSubview:projectName];
    
    UILabel *timeInterval = [[UILabel alloc] initWithFrame:CGRectMake(8, 51, 292, 22)];
    NSDictionary *grayTextAttributes = @{NSForegroundColorAttributeName:[UIColor grayColor]};
    NSMutableAttributedString *updateTime = [[NSMutableAttributedString alloc] initWithString:@"更新于" attributes:grayTextAttributes];
    [updateTime appendAttributedString:[Tools getIntervalAttrStr:_project.lastPushAt]];
    [timeInterval setAttributedText:updateTime];
    [self.view addSubview:timeInterval];
    
    UIButton *starButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 81, 90, 30)];
    [starButton setImage:[UIImage imageNamed:@"star2"] forState:UIControlStateNormal];
    //[starButton setImage:[UIImage imageNamed:@"star2"] forState:UIControlStateSelected];
    [starButton setTitle:[NSString stringWithFormat:@"%i stars", _project.starsCount] forState:UIControlStateNormal];
    //[starButton setTitle:[NSString stringWithFormat:@"%i stars", _project.starsCount+1] forState:UIControlStateSelected];
    [self.view addSubview:starButton];
    
    UIButton *forkButton = [[UIButton alloc] initWithFrame:CGRectMake(172, 81, 90, 30)];
    [forkButton setImage:[UIImage imageNamed:@"fork"] forState:UIControlStateNormal];
    [forkButton setTitle:[NSString stringWithFormat:@"%i forks", _project.forksCount] forState:UIControlStateNormal];
    [self.view addSubview:forkButton];
    
    UITableView *projectTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 119, self.view.frame.size.width, 459)];
    [projectTable registerClass:[UITableViewCell class] forCellReuseIdentifier:ProjectDetailsCellId];
    projectTable.delegate = self;
    projectTable.dataSource = self;
    projectTable.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:projectTable];
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
            int sectionsCount = 1;
            if (_project.parentId) {sectionsCount++;}
            if (_project.projectDescription) {sectionsCount++;}
            return ++sectionsCount;
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
#if 0
    if (indexPath.section == 0 && (indexPath.row == 2 || (indexPath.row == 1 && !_parentProject))) {
        
    }
#endif
    return 40;
}

#if 0
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
}
#endif

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
            } else if (_project.projectDescription) {
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
    //return cell;
}











@end
