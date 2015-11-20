//
//  IssueCreation.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-18.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueCreation : UIViewController <UITextFieldDelegate, UITextViewDelegate>//<UIPickerViewDataSource, UIPickerViewAccessibilityDelegate>

@property int64_t projectId;
@property NSString *projectNameSpace;
@property NSArray *members;
//@property NSArray *milestones;

@property UILabel *titleLabel;
//@property UILabel *consignorLabel;
//@property UILabel *mileStoneLabel;
@property UILabel *descriptionLabel;

@property UITextField *issueTitle;
//@property UIPickerView *consignor;
//@property UIPickerView *milestone;
@property UITextView *issueDescription;

@property UIButton *submit;

@end
