//
//  NoteEditingView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "NoteEditingView.h"
#import "Note.h"

@interface NoteEditingView ()

@end

@implementation NoteEditingView

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
    
    self.title = @"评论";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(sendComment)];
    
    [self setLayout];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gesture.numberOfTapsRequired = 1;
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"private_token"]) {
        BOOL success = [Note createNoteForIssue:_issue body:_noteContent.text];
        if (success) {
            NSLog(@"评论成功");
        } else {
            NSLog(@"评论失败");
        }
    } else {
        NSLog(@"请先登录");
    }
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
    _noteContent.text = @"";
    [_noteContent resignFirstResponder];
}


@end
