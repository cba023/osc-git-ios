//
//  NoteEditingView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class GLIssue;

@interface NoteEditingView : UIViewController <UITextViewDelegate>

@property GLIssue *issue;
@property NSString *projectNameSpace;
@property UITextView *noteContent;

@end
