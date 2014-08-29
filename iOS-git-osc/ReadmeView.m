//
//  ReadmeView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ReadmeView.h"
#import "GLGitlab.h"
#import "Project.h"

@interface ReadmeView ()

@property BOOL isFinishedLoading;
@property NSString *html;

@end

@implementation ReadmeView

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
    //_readme = [[UIWebView alloc] initWithFrame:self.view.bounds];
    //_readme.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //[self.view addSubview:_readme];
    [self initSubviews];
    [self setAutoLayout];
    _isFinishedLoading = NO;
    
    _html = [Project loadReadme:_projectID];
    [_readme loadHTMLString:_html baseURL:nil];
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
        return;
    }
    
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    int widthOfBody = [bodyWidth intValue];
    
    //获取实际要显示的html
    NSString *adjustedHTML = [self htmlAdjustWithPageWidth:widthOfBody
                                              html:_html
                                           webView:webView];
    
    //加载实际要现实的html
    //[webView loadHTMLString:html baseURL:nil];
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
    
    NSString *header = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=no\">", initialScale];
    
    NSString *newHTML = [NSString stringWithFormat:@"<html><head>%@</head><body>%@</body></html>", header, html];
    
    return newHTML;
}




@end
