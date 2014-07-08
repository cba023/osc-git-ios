//
//  FileContentView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-7.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileContentView : UIViewController

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) UIWebView *webView;

@end
