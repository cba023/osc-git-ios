//
//  LastCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-28.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastCell : UITableViewCell

//@property NSInteger status;

@property UIActivityIndicatorView *indicator;
@property UILabel *statusLabel;

- (id)initCell;
- (void)normal;
- (void)loading;
- (void)finishedLoad;
- (void)empty;

@end
