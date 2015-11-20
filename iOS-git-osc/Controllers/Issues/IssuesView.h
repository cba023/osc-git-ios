//
//  IssuesView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssuesView : UITableViewController

@property NSMutableArray *issues;
@property int64_t projectId;

- (id)initWithProjectId:(int64_t)projectId projectNameSpace:(NSString *)nameSpace;

@end
