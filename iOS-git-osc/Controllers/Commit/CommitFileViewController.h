//
//  CommitFileViewController.h
//  Git@OSC
//
//  Created by 李萍 on 15/12/3.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitFileViewController : UIViewController

@property (nonatomic, copy) NSString *projectNameSpace;
@property (nonatomic, copy) NSString *commitIDStr;
@property (nonatomic, copy) NSString *commitFilePath;

@end
