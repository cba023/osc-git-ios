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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(NavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
    self.title = @"问题";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[IssueCell class] forCellReuseIdentifier:cellId];
    
    _issues = [[NSMutableArray alloc] init];
    
    _issues = [Issue getIssuesWithProjectId:_projectId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

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
    
    [cell.title setText:[NSString stringWithFormat:@"<font face='Arial-BoldMT' size=14>%@</font>", issue.title]];
    [cell.description setText:issue.issueDescription];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row < self.issues.count) {
        GLIssue *issue = [_issues objectAtIndex:indexPath.row];
        NotesView *notesView = [[NotesView alloc] init];
        notesView.issue = issue;
        
        [self.navigationController pushViewController:notesView animated:YES];
    }
}


@end
