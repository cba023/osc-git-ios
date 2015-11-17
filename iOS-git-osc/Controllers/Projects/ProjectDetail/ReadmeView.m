//
//  ReadmeView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ReadmeView.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "UIView+Toast.h"
#import "PKRevealController.h"

@interface ReadmeView ()

@property BOOL isFinishedLoading;
@property NSString *html;

@end

@implementation ReadmeView

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSubviews];
    [self setAutoLayout];
    _isFinishedLoading = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = NO;
    
    if (_isFinishedLoading) {return;}
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    }
    
    [self.view makeToastActivity];
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil || responseObject == [NSNull null]) {
            _isFinishedLoading = YES;
            [_readme loadHTMLString:@"该项目暂无Readme文件" baseURL:nil];
        } else {
            _html = responseObject;
            [_readme loadHTMLString:_html baseURL:nil];
        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        [self.view hideToastActivity];
        
        if (error != nil) {
            [Tools toastNotification:[NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code] inView:self.view];
        } else {
            [Tools toastNotification:@"网络错误" inView:self.view];
        }
    };

    [[GLGitlabApi sharedInstance] loadReadmeForProjectID:_projectID
                                            privateToken:[Tools getPrivateToken]
                                                 success:success
                                                 failure:failure];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithProjectID:(int64_t)projectID
{
    self = [super init];
    if (self) {
        _projectID = projectID;
    }
    return self;
}

- (void)initSubviews
{
    _readme = [UIWebView new];
    //_readme = [[UIWebView alloc] initWithFrame:self.view.bounds];   //不用autolayout，这样设置的话，如果内容很长，底部会有些内容显示不全，原因未知
    _readme.delegate = self;
    _readme.scrollView.bounces = NO;
    _readme.opaque = NO;
    _readme.backgroundColor = [UIColor clearColor];
    _readme.scalesPageToFit = NO;
    _readme.hidden = YES;
    [self.view addSubview:_readme];
}

- (void)setAutoLayout
{
    [_readme setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_readme]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_readme)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_readme]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_readme)]];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_isFinishedLoading) {
        webView.hidden = NO;
        [self.view hideToastActivity];
        webView.scalesPageToFit = YES;
        return;
    }
    
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    int widthOfBody = [bodyWidth intValue];
    
    //获取实际要显示的html
    NSString *adjustedHTML = [self htmlAdjustWithPageWidth:widthOfBody
                                              html:_html
                                           webView:webView];
    
    //加载实际要现实的html
    [_readme loadHTMLString:adjustedHTML baseURL:nil];
    
    //设置为已经加载完成
    _isFinishedLoading = YES;
}

//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat)pageWidth
                                 html:(NSString *)html
                              webView:(UIWebView *)webView
{
    //计算要缩放的比例
    CGFloat initialScale = webView.frame.size.width/pageWidth;
    
    NSString *header = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\">", initialScale];
    
    NSString *newHTML = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", header, html];
    
    return newHTML;
}




@end
