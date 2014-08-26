//
//  NotesView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLIssue;

@interface NotesView : UITableViewController

@property GLIssue *issue;
@property NSMutableArray *notes;

@end
