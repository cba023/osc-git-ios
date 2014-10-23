//
//  LastCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-28.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LastCellStatus)
{
    LastCellStatusVisible,
    LastCellStatusNotVisible,
};

@interface LastCell : UITableViewCell

@property UIActivityIndicatorView *indicator;
@property UILabel *statusLabel;
@property LastCellStatus status;

- (id)initCell;

- (void)normal;
- (void)loading;
- (void)finishedLoad;

@end
