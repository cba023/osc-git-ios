//
//  TitleScrollViewController.h
//  Git@OSC
//
//  Created by 李萍 on 15/11/24.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleScrollViewController : UIViewController

@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, strong) NSArray *subTitles;
@property (nonatomic, assign) BOOL isProject;

@property (nonatomic, assign) NSString *privateToken;
@property (nonatomic, assign) int64_t userID;

@property (nonatomic, copy) NSString *portrait;
@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) BOOL isTabbarItem;

@end
