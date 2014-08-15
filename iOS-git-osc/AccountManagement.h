//
//  AccountManagement.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountManagement : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSUserDefaults *userDefaults;

@property UIImageView *portrait;
@property UILabel *name;
@property UITableView *follow;
@property UITableView *social;
@property UIButton *logoutButton;

@end
