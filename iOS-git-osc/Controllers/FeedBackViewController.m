//
//  FeedBackViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/15.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "FeedBackViewController.h"
#import "UIColor+Util.h"
#import "Tools.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "GITAPI.h"

#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>

@interface FeedBackViewController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *feedButton;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"意见反馈";
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor uniformColor];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    [self initSubView];
    
    /*** binding ***/
    
    RACSignal *valid = [RACSignal combineLatest:@[_textView.rac_textSignal]
                                         reduce:^(NSString *feedBackString) {
                                             return @(feedBackString.length > 0);
                                         }];
    RAC(_feedButton, enabled) = valid;
    RAC(_feedButton, alpha) = [valid map:^(NSNumber *b) {
        return b.boolValue ? @1: @0.4;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubView
{
    UILabel *label = [UILabel new];
    label.text = @"请写下您的意见或建议";
    label.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:label];
    
    _textView = [UITextView new];
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.layer.borderWidth = 0.8;
    _textView.layer.cornerRadius = 3.0;
    _textView.layer.borderColor = [[UIColor grayColor] CGColor];
    _textView.returnKeyType = UIReturnKeyDone;
    _textView.autocorrectionType = UITextAutocorrectionTypeNo;
    _textView.delegate = self;
    [self.view addSubview:_textView];
    
    _feedButton = [UIButton new];
    [_feedButton setTitle:@"发表意见" forState:UIControlStateNormal];
    [Tools roundView:_feedButton cornerRadius:5.0];
    [_feedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _feedButton.backgroundColor = [UIColor redColor];
    [self.view addSubview:_feedButton];
    [_feedButton addTarget:self action:@selector(feedBack) forControlEvents:UIControlEventTouchUpInside];
    
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(label, _textView, _feedButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[label(30)]-5-[_textView(150)]-30-[_feedButton(35)]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_textView]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

#pragma mark - 键盘收回
- (void)hidenKeyboard
{
    [_textView resignFirstResponder];
    
}

# pragma mark - 发表意见
- (void)feedBack
{
    NSMutableString *mailUrl = [NSMutableString new];
    //收件人
    NSArray *toRecipients = [NSArray arrayWithObject:@"apposchina@163.com"];
    [mailUrl appendFormat:@"mailto:%@",[toRecipients componentsJoinedByString:@","]];
    //主题
    [mailUrl appendString:@"?subject=用户反馈－git@osc iPhone客户端"];
    //邮件内容
    [mailUrl appendFormat:@"&body=%@", _textView.text];
    NSString *mail = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mail]];

}

@end
