//
//  NoteEditingView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "NoteEditingView.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "LoginViewController.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"

@interface NoteEditingView ()

@end

@implementation NoteEditingView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"评论";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sendComment)];
    
    self.view.backgroundColor = [Tools uniformColor];
    [self setLayout];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 发表评论
- (void)sendComment
{
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    }
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"private_token"]) {
        [self sendForComment];
    } else {
        LoginViewController *loginView = [LoginViewController new];
        [self.navigationController pushViewController:loginView animated:YES];
    }
}

- (void)sendForComment
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/issues/%lld/notes", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace, _issue.issueId];
    NSDictionary *parameters = @{
                                 @"private_token" : [Tools getPrivateToken],
                                 @"body"          :  _noteContent.text
                                 };

    [manager POST:strUrl
       parameters:parameters
          success:^(AFHTTPRequestOperation * operation, id responseObject) {
              if (responseObject == nil) {
                  [Tools toastNotification:@"评论失败" inView:self.view];
              } else {
                  [Tools toastNotification:@"评论成功" inView:self.view];
                  
                  [self.navigationController popViewControllerAnimated:YES];
              }
          } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              if (error != nil) {
                  [Tools toastNotification:[NSString stringWithFormat:@"评论失败，错误码：%ld", (long)error.code] inView:self.view];
              } else {
                  [Tools toastNotification:@"评论失败" inView:self.view];
              }
    }];
    
}

- (void)setLayout
{
    UILabel *prompt = [UILabel new];
    prompt.text = @"我要评论";
    prompt.font = [UIFont systemFontOfSize:14];
    prompt.textColor = [UIColor grayColor];
    [self.view addSubview:prompt];
    
    _noteContent = [UITextView new];
    _noteContent.layer.borderWidth = 0.8;
    _noteContent.layer.cornerRadius = 3.0;
    _noteContent.layer.borderColor = [[UIColor grayColor] CGColor];
    _noteContent.font = [UIFont systemFontOfSize:16];
    _noteContent.enablesReturnKeyAutomatically = YES;
    _noteContent.autocorrectionType = UITextAutocorrectionTypeNo;
    _noteContent.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [_noteContent becomeFirstResponder];
    [self.view addSubview:_noteContent];
    
    for (UIView *view in [self.view subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[prompt]-8-[_noteContent(>=120)]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(prompt, _noteContent)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_noteContent]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_noteContent)]];
}

#pragma mark = keyboard things

- (void)hideKeyboard
{
    [_noteContent resignFirstResponder];
}


@end
