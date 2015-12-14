//
//  CommitDetailViewController.h
//  Git@OSC
//
//  Created by 李萍 on 15/12/2.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLCommit.h"

@interface CommitDetailViewController : UITableViewController

@property (nonatomic, strong) GLCommit *commit;
@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *projectNameSpace;

@end
