//
//  NoteCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@interface NoteCell : UITableViewCell

@property RTLabel *author;
@property RTLabel *body;
@property RTLabel *time;

@end
