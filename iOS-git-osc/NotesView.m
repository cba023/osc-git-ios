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
#import "Tools.h"
#import "CreationInfoCell.h"
#import "IssueDescriptionCell.h"

@interface NotesView ()

@end

static NSString * const NoteCellId = @"NoteCell";
static NSString * const CreationInfoCellId = @"CreationInfoCell";
static NSString * const IssueDescriptionCellId = @"IssueDescriptionCell";

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
    
    [self.tableView registerClass:[NoteCell class] forCellReuseIdentifier:NoteCellId];
    [self.tableView registerClass:[CreationInfoCell class] forCellReuseIdentifier:CreationInfoCellId];
    [self.tableView registerClass:[IssueDescriptionCell class] forCellReuseIdentifier:IssueDescriptionCellId];
    _notes = [Note getNotesForIssue:_issue page:1];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"评论"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(editComment)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _notes.count == 0? 1: 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
        case 1:
            return _notes.count;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section, row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {return 41;}
        else {return 150;}
    } else {
        return 90;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _issue.title;
    } else {
        return [NSString stringWithFormat:@"%lu条评论", _notes.count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 0) {
        CreationInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CreationInfoCellId forIndexPath:indexPath];
        
        [Tools setPortraitForUser:_issue.author view:cell.portrait cornerRadius:2.0];
        NSString *timeInterval = [Tools intervalSinceNow:_issue.createdAt];
        NSString *creationInfo = [NSString stringWithFormat:@"%@在%@创建该问题", _issue.author.name, timeInterval];
        [cell.creationInfo setText:creationInfo];
        
        return cell;
    } else if (section == 0 && row == 1) {
        IssueDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:IssueDescriptionCellId forIndexPath:indexPath];
        NSString *html = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"user-scalable=no, width=device-width\"></head><body>%@</body><html>", _issue.issueDescription];
        
        [cell.issueDescription loadHTMLString:html baseURL:nil];
        
        return cell;
    } else {
        NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:NoteCellId forIndexPath:indexPath];
        GLNote *note = [_notes objectAtIndex:row];
        
        [Tools setPortraitForUser:note.author view:cell.portrait cornerRadius:2.0];
        [cell.author setText:note.author.name];
        NSString *html = [NSString stringWithFormat:@"<html><head><meta name=\"viewport\" content=\"user-scalable=no, width=device-width\"></head><body>%@</body><html>", note.body];
        [cell.body loadHTMLString:html baseURL:nil];
        [cell.time setAttributedText:[Tools getIntervalAttrStr:note.createdAt]];
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    return 40;
}

#pragma mark - 编辑评论
- (void)editComment
{
    NoteEditingView *noteEditingView = [[NoteEditingView alloc] init];
    noteEditingView.issue = _issue;
    [self.navigationController pushViewController:noteEditingView animated:YES];
}


@end
