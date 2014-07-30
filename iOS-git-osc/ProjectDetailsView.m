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
        _parentProject = [Project getASingleProject:_parentProject.parentId];
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

    if (indexPath.section == 0) {
    } else
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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
    
}

- (UITableViewCell *)generateTabelCell:(UITableViewCell *)cell inRow:(NSInteger)row
{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *nameAttributes = @{NSForegroundColorAttributeName: [UIColor grayColor]};
    
    switch (row) {
        case 0: {
            UILabel *owner = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
            NSMutableAttributedString *ownerAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"拥有者" attributes:nameAttributes];
            [ownerAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:_project.owner.name]];
            [owner setAttributedText:ownerAttrTxt];
            [cell addSubview:owner];
            break;
        }
        case 3: {
            UILabel *readme = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
            [readme setText:@"README"];
            [cell addSubview:readme];
            break;
        }
        case 2: {
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
            [description setText:_project.projectDescription];
            cell.accessoryType = UITableViewCellAccessoryNone;
            [cell addSubview:description];
            break;
        }
        case 1: {
            UILabel *forkFrom = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
            NSMutableAttributedString *forkFromAttrTxt = [[NSMutableAttributedString alloc] initWithString:@"forkFrom" attributes:nameAttributes];
            [forkFromAttrTxt appendAttributedString:[[NSAttributedString alloc] initWithString:_parentProject.name]];
            [forkFrom setAttributedText:forkFromAttrTxt];
            [cell addSubview:forkFrom];
            break;
        }
        default:
            break;
    }
    return cell;
}











@end
