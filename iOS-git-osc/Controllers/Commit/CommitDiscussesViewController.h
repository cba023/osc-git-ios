//
//  CommitDiscussesViewController.h
//  Git@OSC
//
//  Created by 李萍 on 15/12/14.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommitDiscussesViewController : UITableViewController

@property (nonatomic, copy) NSString *projectNameSpace;
@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *commitID;

@end
