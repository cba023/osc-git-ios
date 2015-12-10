//
//  FileContentView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-7.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileContentView : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *projectNameSpace;
@property (nonatomic, copy) NSString *path;
@property (strong, nonatomic) NSString *fileName;

@property (strong, nonatomic) NSString *content;

@property (strong, nonatomic) UIWebView *webView;

- (id)initWithProjectID:(int64_t)projectID path:(NSString *)path fileName:(NSString *)fileName projectNameSpace:(NSString *)nameSpace;

@end
