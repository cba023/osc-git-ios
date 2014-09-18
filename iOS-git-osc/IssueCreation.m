//
//  IssueCreation.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-18.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssueCreation.h"
#import "Issue.h"
#import "Project.h"
#import "Tools.h"
#import "GLGitlab.h"
#import "Issue.h"
#import "UIView+Toast.h"

@interface IssueCreation ()

@end

@implementation IssueCreation

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"创建Issue";
    self.view.backgroundColor = [Tools uniformColor];
    
    //[self getMembersAndMilestones];
    [self initSubviews];
    [self setAutoLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#if 0
- (void)getMembersAndMilestones
{
    _members = [Project getTeamMembersForProjectId:_projectId];
    _milestones = [Issue getMilestonesForProjectId:_projectId page:1];
}
#endif

- (void)initSubviews
{
    _titleLabel = [UILabel new];
    _titleLabel.text = @"标题";
    [self.view addSubview:_titleLabel];
    
    _issueTitle = [UITextField new];
    _issueTitle.backgroundColor = [UIColor whiteColor];
    _issueTitle.layer.borderWidth = 0.8;
    _issueTitle.layer.cornerRadius = 3.0;
    _issueTitle.returnKeyType = UIReturnKeyNext;
    _issueTitle.layer.borderColor = [[UIColor grayColor] CGColor];
    _issueTitle.enablesReturnKeyAutomatically = YES;
    _issueTitle.delegate = self;
    [self.view addSubview:_issueTitle];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.text = @"描述";
    [self.view addSubview:_descriptionLabel];
    
    _description = [UITextView new];
    _description.backgroundColor = [UIColor whiteColor];
    _description.layer.borderWidth = 0.8;
    _description.layer.cornerRadius = 3.0;
    _description.layer.borderColor = [[UIColor grayColor] CGColor];
    _description.returnKeyType = UIReturnKeyDone;
    _description.autocorrectionType = UITextAutocorrectionTypeNo;
    _description.delegate = self;
    [self.view addSubview:_description];
    
    [_issueTitle addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    _submit = [UIButton buttonWithType:UIButtonTypeCustom];
    [Tools roundView:_submit cornerRadius:5.0];
    _submit.backgroundColor = [UIColor redColor];
    _submit.alpha = 0.4;
    _submit.enabled = NO;
    [_submit setTitle:@"创建Issue" forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(submitIssue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submit];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_titleLabel]-[_issueTitle(40)]-20-[_descriptionLabel]-[_description(150)]-30-[_submit(30)]"
                                                                     options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_titleLabel, _issueTitle,
                                                                                                            _descriptionLabel, _description,
                                                                                                            _submit)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_submit]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_submit)]];
}

- (void)submitIssue
{
    GLIssue *issue = [GLIssue new];
    issue.projectId = _projectId;
    issue.title = _issueTitle.text;
    issue.issueDescription = _description.text;
    [self createIssue:issue];
}

- (void)createIssue:(GLIssue *)issue
{
    if (![Tools isNetworkExist]) {
         [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    }
    
    [self.view makeToastActivity];
    NSString *privateToken = [Tools getPrivateToken];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            [Tools toastNotification:@"网络错误" inView:self.view];
        } else {
            [self.view hideToastActivity];
            [Tools toastNotification:@"Issue 创建成功" inView:self.view];
        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        [self.view hideToastActivity];
        if (error != nil) {
            [Tools toastNotification:[error description] inView:self.view];
        }
    };
    
    [[GLGitlabApi sharedInstance] createIssue:issue
                                 privateToken:privateToken
                             withSuccessBlock:success
                              andFailureBlock:failure];
}

#pragma mark - 键盘操作

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat y;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        y = -40;
    } else {
        y = -95;
    }
    
    CGRect rect = CGRectMake(0.0f, y, width, height);
    self.view.frame = rect;
    
    [UIView commitAnimations];
    
    return YES;
}

- (void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat y;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        y = 64;
    } else {
        y = 0;
    }
    
    CGRect rect=CGRectMake(0.0f, y, width, height);
    self.view.frame=rect;

    [UIView commitAnimations];
}

- (void)hidenKeyboard
{
    [self.issueTitle resignFirstResponder];
    [self.description resignFirstResponder];
    
    [self resumeView];
}

//点击键盘上的Return按钮响应的方法
- (void)returnOnKeyboard:(UITextField *)sender
{
    [self.description becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString: @"\n"]) {
        [self hidenKeyboard];
        [self submitIssue];
        return NO;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *newStr = [textField.text mutableCopy];
    [newStr replaceCharactersInRange:range withString:string];
    
    if (newStr.length) {
        _submit.alpha = 1;
        _submit.enabled = YES;
    } else {
        _submit.alpha = 0.4;
        _submit.enabled = NO;
    }
    
    return YES;
}



@end
