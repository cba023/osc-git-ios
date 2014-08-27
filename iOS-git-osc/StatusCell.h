//
//  StatusCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-27.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatusCell : UITableViewCell

@property NSInteger status;

- (id)initWithStatus:(NSInteger)status;

@end
