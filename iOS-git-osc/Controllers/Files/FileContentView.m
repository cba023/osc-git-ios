//
//  FileContentView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-7.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "FileContentView.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "UIView+Toast.h"
#import "PKRevealController.h"

#import "GITAPI.h"
#import "AFHTTPRequestOperationManager+Util.h"

@interface FileContentView ()

@end

@implementation FileContentView

- (id)initWithProjectID:(int64_t)projectID path:(NSString *)path fileName:(NSString *)fileName projectNameSpace:(NSString *)nameSpace
{
    self = [super init];
    if (self) {
        _projectID = projectID;
        _path = path;
        _fileName = fileName;
        _projectNameSpace = nameSpace;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.fileName;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
    
    [self fetchFileContent];
}

#pragma mark - 获取文件数据

- (void)fetchFileContent
{
    self.revealController.frontViewController.revealController.recognizesPanningOnFrontView = NO;
    
    [self.view makeToastActivity];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/files", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS, _projectNameSpace];
    NSDictionary *parameters = @{
                                 @"private_token" : [Tools getPrivateToken],
                                 @"ref"           : @"master",
                                 @"file_path"     : [NSString stringWithFormat:@"%@%@", _path, _fileName]
                                 };
    
    [manager GET:strUrl
      parameters:parameters
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (responseObject == nil) {
                 [self.view hideToastActivity];
                 [Tools toastNotification:@"网络错误" inView:self.view];
             } else {
                 _content = [[GLBlob alloc] initWithJSON:responseObject].content;
                 [self render];
             }
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             [self.view hideToastActivity];
             
             if (![Tools isNetworkExist]) {
                 [Tools toastNotification:@"错误 网络异常" inView:self.view];
             } else {
                 [Tools toastNotification:@"网络错误" inView:self.view];
             }
    }];
}

- (void)popBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)render
{
    NSURL *baseUrl = [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath];
	BOOL lineNumbers = YES;//[[defaults valueForKey:kLineNumbersDefaultsKey] boolValue];
    NSString *lang = [[_fileName componentsSeparatedByString:@"."] lastObject];
	NSString *theme = @"github";//@"tomorrow-night";//[defaults valueForKey:kThemeDefaultsKey];
	NSString *formatPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"html"];
	NSString *highlightJsPath = [[NSBundle mainBundle] pathForResource:@"highlight.pack" ofType:@"js"];
	NSString *themeCssPath = [[NSBundle mainBundle] pathForResource:theme ofType:@"css"];
	NSString *codeCssPath = [[NSBundle mainBundle] pathForResource:@"code" ofType:@"css"];
	NSString *lineNums = lineNumbers ? @"true" : @"false";
	NSString *format = [NSString stringWithContentsOfFile:formatPath encoding:NSUTF8StringEncoding error:nil];
	NSString *escapedCode = [Tools escapeHTML:_content];
	NSString *contentHTML = [NSString stringWithFormat:format, themeCssPath, codeCssPath, highlightJsPath, lineNums, lang, escapedCode];
    
	[self.webView loadHTMLString:contentHTML baseURL:baseUrl];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.view hideToastActivity];
}


@end
