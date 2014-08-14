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
    _readme = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _readme.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_readme];
    
    NSString *html = [Project loadReadme:_projectID];
    [_readme loadHTMLString:html baseURL:nil];
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


@end
