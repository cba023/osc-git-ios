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
    
    UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStyleBordered target:self action:@selector(sendComment)];
    self.navigationItem.rightBarButtonItem = sendButton;
    
    _noteContent = [[UITextView alloc] initWithFrame:self.view.bounds];
    _noteContent.editable = YES;
    _noteContent.delegate = self;
    _noteContent.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _noteContent.font = [UIFont systemFontOfSize:18];
    _noteContent.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:_noteContent];
    [_noteContent becomeFirstResponder];
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

@end
