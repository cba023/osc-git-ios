//
//  ReadmeView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReadmeView : UIViewController <UIWebViewDelegate>

@property int64_t projectID;
@property NSString *projectNameSpace;
@property UIWebView *readme;

- (id)initWithProjectID:(int64_t)projectID projectNameSpace:(NSString *)nameSpace;

@end
