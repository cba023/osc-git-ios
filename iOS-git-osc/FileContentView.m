//
//  FileContentView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-7.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "FileContentView.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(popBack)];
    self.title = self.fileName;
#if 0
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 640, 480)];
    self.webView.multipleTouchEnabled = YES;
#else
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    //NSLog(@"bounds x:%f y:%f", self.view.bounds.origin.x, self.view.bounds.origin.y);
    //NSLog(@"bounds w:%f h:%f", self.view.bounds.size.width, self.view.bounds.size.height);
#endif
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.webView loadHTMLString:self.content baseURL:nil];
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


@end
