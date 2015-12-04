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
#import "UIView+Toast.h"
#import "AFHTTPRequestOperationManager+Util.h"

@interface CommitFileViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *fileName;

@end

@implementation CommitFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([_commitFilePath rangeOfString:@"/"].location !=NSNotFound) {
        NSArray *array = [_commitFilePath componentsSeparatedByString:@"/"];
        _fileName = array[array.count-1];
    } else {
        _fileName = _commitFilePath;
    }
    
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
    if (![Tools isNetworkExist]) {
        
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    }
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/%@/repository/commits/%@/blob",
                        GITAPI_HTTPS_PREFIX,
                        GITAPI_PROJECTS,
                        _projectNameSpace,
                        _commitIDStr];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"filepath"      : _commitFilePath,
                                                                                      @"private_token" : [Tools getPrivateToken]
                                                                                      }];
    
    if ([Tools getPrivateToken].length == 0) {
        [parameters removeObjectForKey:@"private_token"];
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [self.view makeToastActivity];
    
    [manager GET:strUrl
      parameters:parameters
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             
             
             if (responseObject == nil) {} else {
                 NSString *resStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                 _content = resStr;
                 [self render];
                 [self.view hideToastActivity];
             }
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             NSLog(@"%@", error);
             [self.view hideToastActivity];
             
             if (error != nil) {
                 [Tools toastNotification:[NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code] inView:self.view];
             } else {
                 [Tools toastNotification:@"网络错误" inView:self.view];
             }
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
