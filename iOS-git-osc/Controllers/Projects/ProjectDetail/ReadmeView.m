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

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import <MBProgressHUD.h>

@interface ReadmeView ()

@property (nonatomic, assign) BOOL isFinishedLoading;
@property (nonatomic, copy) NSString *html;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ReadmeView

- (id)initWithProjectID:(int64_t)projectID  projectNameSpace:(NSString *)nameSpace
{
    self = [super init];
    if (self) {
        _projectID = projectID;
        _projectNameSpace = nameSpace;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSubviews];
    [self setAutoLayout];
    _isFinishedLoading = NO;
    
    [self fetchProjectReadMeDetail];
}

#pragma mark - 获取数据
- (void)fetchProjectReadMeDetail
{
    if (_isFinishedLoading) {return;}
    
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    //不再使用namespace作为或许项目详情的参数，转而使用projectID，这样更加靠谱
    NSString *projectIdStr = [NSString stringWithFormat:@"%lld",_projectID];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/readme?private_token=%@", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, projectIdStr, [Tools getPrivateToken]];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [_hud hide:YES afterDelay:1];
             
             if (responseObject == nil || responseObject == [NSNull null]) {
                 _isFinishedLoading = YES;
                 [_readme loadHTMLString:@"该项目暂无Readme文件" baseURL:nil];
             } else {
                 _html = [responseObject objectForKey:@"content"];
                 if (_html != nil && ![_html isKindOfClass:[NSNull class]]) {
                     [_readme loadHTMLString:_html baseURL:nil];
                 } else {
                     [_hud show:YES];
                     _hud.mode = MBProgressHUDModeCustomView;
                     _hud.detailsLabelText = @"无ReadMe文件";
                     [_hud hide:YES afterDelay:1.0];
                 }
                 
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
