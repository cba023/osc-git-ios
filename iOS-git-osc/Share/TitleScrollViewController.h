//
//  TitleScrollViewController.h
//  Git@OSC
//
//  Created by 李萍 on 15/11/24.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TitleScrollViewController : UIViewController

@property (nonatomic, assign) BOOL isTabbarItem;

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)titles andSubControllers:(NSArray *)controllers andUnderTabbar:(BOOL)underTabbar andUserPortrait:(BOOL)userPortrait;

@end
