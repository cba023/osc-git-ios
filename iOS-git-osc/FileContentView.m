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

@interface FileContentView ()

@end

@implementation FileContentView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithProjectID:(int64_t)projectID path:(NSString *)path fileName:(NSString *)fileName
{
    self = [super init];
    if (self) {
        _projectID = projectID;
        _path = path;
        _fileName = fileName;
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view makeToastActivity];
    
    [[GLGitlabApi sharedInstance] getFileContentFromProject:_projectID
                                               privateToken:[Tools getPrivateToken]
                                                       path:[NSString stringWithFormat:@"%@%@", _path, _fileName]
                                                 branchName:@"master"
                                               successBlock:^(id responseObject) {
                                                   [self.view hideToastActivity];
                                                   
                                                   if (responseObject == nil) {
                                                       [Tools toastNotification:@"网络错误" inView:self.view];
                                                   } else {
                                                       _content = ((GLBlob *)responseObject).content;
                                                       [self render];
                                                   }
                                               }
                                               failureBlock:^(NSError *error) {
                                                   [self.view hideToastActivity];
                                                   
                                                   if (![Tools isNetworkExist]) {
                                                       [Tools toastNotification:@"错误 网络异常" inView:self.view];
                                                   } else {
                                                       [Tools toastNotification:@"网络错误" inView:self.view];
                                                   }
                                               }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(popBack)];
    self.title = self.fileName;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:self.webView];
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
	NSString *theme = @"tomorrow-night";//[defaults valueForKey:kThemeDefaultsKey];
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
