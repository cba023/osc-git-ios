//
//  AboutViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/26.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "AboutViewController.h"

#import "UIColor+Util.h"
@interface AboutViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"关于";

    [self initWithViews];
}

- (void)initWithViews
{
    _imageView = [UIImageView new];
    _imageView.layer.cornerRadius = 5;
    _imageView.clipsToBounds = YES;
    _imageView.image = [UIImage imageNamed:@"loginLogo"];
    [self.view addSubview:_imageView];
    
    _versionLabel = [UILabel new];
    _versionLabel.font = [UIFont systemFontOfSize:16];
    _versionLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
    _versionLabel.text = [NSString stringWithFormat:@"V %@ (%@)", version,build];
    _versionLabel.textColor = [UIColor colorWithHex:0x474747];
    [self.view addSubview:_versionLabel];
    
    _messageLabel = [UILabel new];
    _messageLabel.font = [UIFont systemFontOfSize:16];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.numberOfLines = 0;
    _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _messageLabel.text = @"©2016 OSChina.net  All rights reserved";
    _messageLabel.textColor = [UIColor colorWithHex:0x474747];
    [self.view addSubview:_messageLabel];
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _versionLabel, _messageLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-84-[_imageView(80)]-10-[_versionLabel]"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_messageLabel]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_imageView(80)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_versionLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_messageLabel]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
