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
#import "Tools.h"
#import "CreationInfoCell.h"
#import "IssueDescriptionCell.h"
#import "TitleScrollViewController.h"
#import "EventsView.h"
#import "ProjectsTableController.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import <MBProgressHUD.h>

@interface NotesView ()

@property (nonatomic, assign) BOOL isLoadingFinished;
@property (nonatomic) CGFloat webViewHeight;
@property (nonatomic, copy) NSString *issueContentHTML;
@property (nonatomic, strong) MBProgressHUD *hud;

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
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    self.tableView.bounces = NO;
    
    _notes = [NSMutableArray new];
    _issueContentHTML = _issue.issueDescription;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"评论"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(editComment)];
    
    [self fetchIssueNotesOnPage:1];
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
        if (row == 0) {
            return 41;
        }
        else {
            return _webViewHeight + 10;
        }
    } else {
        GLNote *note = [_notes objectAtIndex:row];
        
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = [UIFont systemFontOfSize:16];
        label.text = [Tools flattenHTML:note.body];
        
        CGSize size = [label sizeThatFits:CGSizeMake(tableView.frame.size.width - 8, MAXFLOAT)];
        
        return size.height + 54;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%lu条评论", (unsigned long)_notes.count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section > 0) {return nil;}
    UIView *headerView = [UIView new];
    headerView.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
    UITextView *titleText = [UITextView new];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.font = [UIFont boldSystemFontOfSize:13];
    [headerView addSubview:titleText];
    titleText.translatesAutoresizingMaskIntoConstraints = NO;
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleText]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(titleText)]];
    
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[titleText]-8-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:NSDictionaryOfVariableBindings(titleText)]];
    
    
    if (section == 0) {
        titleText.text = _issue.title;
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 0) {
        CreationInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CreationInfoCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [Tools setPortraitForUser:_issue.author view:cell.portrait cornerRadius:2.0];
        NSString *timeInterval = [Tools intervalSinceNow:_issue.createdAt];
        NSString *creationInfo = [NSString stringWithFormat:@"%@在%@创建该问题", _issue.author.name, timeInterval];
        [cell.creationInfo setText:creationInfo];
        
        return cell;
    } else if (section == 0 && row == 1) {
        IssueDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:IssueDescriptionCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.issueDescription.delegate = self;
        cell.issueDescription.hidden = YES;
        
        [cell.issueDescription loadHTMLString:_issueContentHTML baseURL:nil];
        
        return cell;
    } else {
        NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:NoteCellId forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self configureNoteCell:cell forRowInSection:indexPath.row];
        UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(tapPortrait:)];
        cell.portrait.tag = indexPath.row;
        cell.portrait.userInteractionEnabled = YES;
        [cell.portrait addGestureRecognizer:tapPortraitRecognizer];
        
        return cell;
    }
}

- (void)configureNoteCell:(NoteCell *)noteCell forRowInSection:(NSInteger)row
{
    GLNote *note = [_notes objectAtIndex:row];
    
    [Tools setPortraitForUser:note.author view:noteCell.portrait cornerRadius:2.0];
    [noteCell.author setText:note.author.name];
    noteCell.body.text = [Tools flattenHTML:note.body];
    [noteCell.time setAttributedText:[Tools getIntervalAttrStr:note.createdAt]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        UITextView *titleView = [UITextView new];
        titleView.text = _issue.title;
        titleView.font = [UIFont boldSystemFontOfSize:13];
        
        CGSize size = [titleView sizeThatFits:CGSizeMake(300, MAXFLOAT)];
        
        return size.height;
    }
    return 35;
}

#pragma mark - 设置分割线对齐
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - recognizer头像
- (void)tapPortrait:(UITapGestureRecognizer *)sender
{
    GLNote *note = [_notes objectAtIndex:((UIImageView *)sender.view).tag];
    
    TitleScrollViewController *ownDetailsView = [[TitleScrollViewController alloc] initWithTitle:note.author.name
                                                                                    andSubTitles:@[@"动态", @"项目", @"Star", @"Watch"]
                                                                               andSubControllers:@[
                                                                                                   [[EventsView alloc] initWithUserID:note.author.userId],                                                                                                   [[ProjectsTableController alloc] initWithUserID:note.author.userId andProjectsType:ProjectsTypeUserProjects],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:note.author.userId andProjectsType:ProjectsTypeStared],
                                                                                                   [[ProjectsTableController alloc] initWithUserID:note.author.userId andProjectsType:ProjectsTypeWatched]
                                                                                                   ]
                                                                                  andUnderTabbar:NO
                                                                                 andUserPortrait:NO];
    
    [self.navigationController pushViewController:ownDetailsView animated:YES];
}


#pragma mark - 获取评论

- (void)fetchIssueNotesOnPage:(NSUInteger)page
{
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/issues/%lld/notes?private_token=%@&&page=%lu", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, _issue.issueId, [Tools getPrivateToken], (unsigned long)page];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             [_hud hide:YES afterDelay:1];
             
             if (responseObject == nil) { } else {
                 [responseObject enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                     GLNote *note = [[GLNote alloc] initWithJSON:obj];
                     [_notes addObject:note];
                 }];
                
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.tableView reloadData];
                 });
             }
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             if (error != nil) {
                 _hud.detailsLabelText = [NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code];
             } else {
                 _hud.detailsLabelText = @"网络错误";
             }
             [_hud hide:YES afterDelay:1];
         }];
}

#pragma mark - UIWebView things

//http://borissun.iteye.com/blog/2023712 helps a lot

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_isLoadingFinished) {
        webView.hidden = NO;
        return;
    }
    
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    int widthOfBody = [bodyWidth intValue];
    
    //获取实际要显示的html
    _issueContentHTML = [self htmlAdjustWithPageWidth:widthOfBody
                                                 html:_issue.issueDescription
                                              webView:webView];
    
    //加载实际要现实的html
    //[webView loadHTMLString:html baseURL:nil];
    NSIndexPath *path = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    
    //设置为已经加载完成
    _isLoadingFinished = YES;
}

//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat)pageWidth
                                 html:(NSString *)html
                              webView:(UIWebView *)webView
{
    //计算要缩放的比例
    CGFloat initialScale = webView.frame.size.width/pageWidth;
    _webViewHeight = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue] * initialScale;
    
    NSString *header = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=no\">", initialScale];
    
    NSString *newHTML = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", header, html];
    
    return newHTML;
}

#pragma mark - 编辑评论
- (void)editComment
{
    NoteEditingView *noteEditingView = [[NoteEditingView alloc] init];
    noteEditingView.issue = _issue;
    noteEditingView.projectNameSpace = _projectNameSpace;
    [self.navigationController pushViewController:noteEditingView animated:YES];
}


@end
