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
#import "DataSetObject.h"
#import <MBProgressHUD.h>

@interface CommitFileViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *fileName;

@property (nonatomic,strong) DataSetObject *emptyDataSet;
@property (nonatomic, strong) MBProgressHUD *hud;

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
    self.view.backgroundColor = UIColorFromRGB(0xf0f0f0);
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.scrollView.bounces = NO;
    self.webView.delegate = self;
    
    [self.view addSubview:self.webView];
    
    [self fetchCommitFile];
    self.emptyDataSet = [[DataSetObject alloc]initWithSuperScrollView:self.webView.scrollView];
    __weak CommitFileViewController *weakSelf = self;
    self.emptyDataSet.reloading = ^{
        [weakSelf fetchCommitFile];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取数据
- (void)fetchCommitFile
{
    self.emptyDataSet.state = loadingState;
    
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    
    
    
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
    
    [manager GET:strUrl
      parameters:parameters
         success:^(AFHTTPRequestOperation * operation, id responseObject) {
             [_hud hide:YES afterDelay:1];
             
            if (responseObject == nil) {} else {
                 NSString *resStr = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                 _content = resStr;
                 [self render];
                
                if (_content.length == 0) {
                    self.emptyDataSet.state = noDataState;
                    self.emptyDataSet.respondString = @"还没有相应文件";
                }
             }
             
         } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
             self.emptyDataSet.state = netWorkingErrorState;
             if (error != nil) {
                 _hud.detailsLabelText = [NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code];
             } else {
                 _hud.detailsLabelText = @"网络错误";
             }
             [_hud hide:YES afterDelay:1];
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
