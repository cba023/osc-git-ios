//
//  EventCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTLabel.h"

@class GLEvent;

@interface EventCell : UITableViewCell

@property UIImageView *userPortrait;
@property UITextView *eventDescription;
@property UITextView *eventAbstract;
@property UILabel *time;

- (void)generateEventAbstractView:(GLEvent *)event;
- (void)generateEventDescriptionView:(GLEvent *)event;

@end
