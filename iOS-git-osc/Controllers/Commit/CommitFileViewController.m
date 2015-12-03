//
//  CommitFileViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/3.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "CommitFileViewController.h"
#import "GITAPI.h"
#import "Tools.h"
#import "AFHTTPRequestOperationManager+Util.h"

@interface CommitFileViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *fileName;

@end

@implementation CommitFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSArray *array = [_commitFilePath componentsSeparatedByString:@"/"];
    _fileName = array[array.count-1];
    
    self.navigationItem.title = _fileName;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
    
    [self fetchCommitFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchCommitFile
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/commits/%@/blob?filepath=%@",
                        GITAPI_HTTPS_PREFIX,
                        GITAPI_PROJECTS,
                        _projectNameSpace,
                        _commitIDStr,
                        _commitFilePath];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:strUrl
      parameters:nil
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             if (responseObject == nil) {} else {
                 NSString *resStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                 _content = resStr;
                 [self render];
             }
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {

         }];
    
}

- (void)render
{
    NSURL *baseUrl = [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath];
    BOOL lineNumbers = YES;
    NSString *lang = [[_fileName componentsSeparatedByString:@"."] lastObject];
    NSString *theme = @"github";
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

@end
