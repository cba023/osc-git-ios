//
//  IssueCreation.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-18.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IssueCreation : UIViewController

@property UILabel *titleLabel;
@property UILabel *consignorLabel;
@property UILabel *mileStoneLabel;
@property UILabel *descriptionLabel;

@property UITextField *issueTitle;
@property UIPickerView *consignor;
@property UIPickerView *mileStone;
@property UITextView *description;

@property UIButton *submit;

@end
