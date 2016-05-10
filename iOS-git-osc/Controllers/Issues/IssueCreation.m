//
//  IssueCreation.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-18.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssueCreation.h"
#import "Issue.h"
#import "Tools.h"
#import "GLGitlab.h"
#import "UIView+Toast.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"

#import <MBProgressHUD.h>

@interface IssueCreation ()

@property (nonatomic, strong) MBProgressHUD *hud;

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
    
    _issueDescription = [UITextView new];
    _issueDescription.backgroundColor = [UIColor whiteColor];
    _issueDescription.layer.borderWidth = 0.8;
    _issueDescription.layer.cornerRadius = 3.0;
    _issueDescription.layer.borderColor = [[UIColor grayColor] CGColor];
    _issueDescription.returnKeyType = UIReturnKeyDone;
    _issueDescription.autocorrectionType = UITextAutocorrectionTypeNo;
    _issueDescription.delegate = self;
    [self.view addSubview:_issueDescription];
    
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
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_titleLabel, _issueTitle, _descriptionLabel, _issueDescription, _submit);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_titleLabel]-[_issueTitle(40)]-20-[_descriptionLabel]-[_issueDescription(150)]-30-[_submit(35)]"
                                                                     options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                     metrics:nil
                                                                       views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_submit]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
}

- (void)submitIssue
{
    GLIssue *issue = [GLIssue new];
    issue.projectId = _projectId;
    issue.title = _issueTitle.text;
    issue.issueDescription = _issueDescription.text;

    [self createNewIssue:issue];
}

- (void)createNewIssue:(GLIssue *)issue
{
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = MBProgressHUDModeCustomView;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectId];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/issues", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, projectIdStr];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[issue jsonCreateRepresentation]];
    [params setObject:[Tools getPrivateToken] forKey:@"private_token"];
    
    [manager POST:strUrl
       parameters:params
          success:^(AFHTTPRequestOperation * operation, id responseObject) {
            if (responseObject == nil) {
                _hud.detailsLabelText = @"网络错误";
            } else {
                _hud.detailsLabelText = @"Issue 创建成功";
                
                [self.navigationController popViewControllerAnimated:YES];
            }
              [_hud hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              if (error != nil) {
                  _hud.detailsLabelText = [NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code];
              } else {
                  _hud.detailsLabelText = @"网络错误";
              }
              [_hud hide:YES afterDelay:1];
    }];
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
    [_issueTitle resignFirstResponder];
    [_issueDescription resignFirstResponder];
    
    [self resumeView];
}

//点击键盘上的Return按钮响应的方法
- (void)returnOnKeyboard:(UITextField *)sender
{
    [_issueDescription becomeFirstResponder];
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
