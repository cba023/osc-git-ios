//
//  LoginViewController.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) UITableView* loginTableView;
@property (nonatomic, strong) UITextField* accountTextField;
@property (nonatomic, strong) UITextField* passwordTextField;

- (void)login;

@end
