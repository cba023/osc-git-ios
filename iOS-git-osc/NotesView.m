//
//  NotesView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "NotesView.h"
#import "NoteCell.h"
#import "NoteEditingView.h"
#import "GLGitlab.h"
#import "Note.h"

@interface NotesView ()

@end

static NSString * const cellId = @"NoteCell";

@implementation NotesView

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
    
    [self.tableView registerClass:[NoteCell class] forCellReuseIdentifier:cellId];
    _notes = [Note getNotesForIssue:_issue];
    
    UIBarButtonItem *commentButton = [[UIBarButtonItem alloc] initWithTitle:@"评论" style:UIBarButtonItemStyleBordered target:self action:@selector(editComment)];
    self.navigationItem.rightBarButtonItem = commentButton;
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
    return _notes.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    GLNote *note = [_notes objectAtIndex:indexPath.row];
    cell.author.text = note.author.name;
    cell.body.text = note.body;
    
    return cell;
}

#if 0
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NoteEditingView *noteEditingView = [[NoteEditingView alloc] init];
    [self.navigationController pushViewController:noteEditingView animated:YES];
}
#endif

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
{
    NSString *author = _issue.author.name;
    NSString *description = _issue.issueDescription;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
    
    UILabel *authorField = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, 0, 0)];
    authorField.text = author;
    authorField.font = [UIFont systemFontOfSize:15];
    authorField.textColor = [UIColor whiteColor];
    authorField.backgroundColor = [UIColor clearColor];
    [authorField sizeToFit];
    [view addSubview:authorField];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 30, 30)];
    label.text = description;
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 90;
}

#pragma mark - 编辑评论
- (void)editComment
{
    NoteEditingView *noteEditingView = [[NoteEditingView alloc] init];
    noteEditingView.issue = _issue;
    [self.navigationController pushViewController:noteEditingView animated:YES];
}


@end
