//
//  IssuesView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssuesView.h"
#import "IssueCell.h"
#import "Issue.h"
#import "NavigationController.h"
#import "GLGitlab.h"
#import "NotesView.h"
#import "IssueCreation.h"
#import "Tools.h"

@interface IssuesView ()

@end

static NSString * const cellId = @"IssueCell";

@implementation IssuesView

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
    
    self.title = @"问题";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"创建Issue"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(pushIssueCreationView)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[IssueCell class] forCellReuseIdentifier:cellId];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    _issues = [[NSMutableArray alloc] initWithArray:[Issue getIssuesWithProjectId:_projectId page:1]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithProjectId:(int64_t)projectId
{
    self = [super init];
    if (self) {
        self.projectId = projectId;
    }
    
    return self;
}

#pragma mark - UITableviewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _issues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IssueCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    GLIssue *issue = [_issues objectAtIndex:indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [Tools setPortraitForUser:issue.author view:cell.portrait cornerRadius:5.0];
    [cell.title setText:issue.title];
    [cell.issueInfo setAttributedText:[Issue generateIssueInfo:issue]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.issues.count) {
        GLIssue *issue = [_issues objectAtIndex:indexPath.row];
        NotesView *notesView = [[NotesView alloc] init];
        notesView.issue = issue;
        notesView.title = [NSString stringWithFormat:@"#%lld", issue.issueIid];
        
        [self.navigationController pushViewController:notesView animated:YES];
    }
}

#pragma mark - pushIssueCreationView

- (void)pushIssueCreationView
{
    IssueCreation *issueCreationView = [IssueCreation new];
    issueCreationView.projectId = self.projectId;
    [self.navigationController pushViewController:issueCreationView animated:YES];
}


@end
