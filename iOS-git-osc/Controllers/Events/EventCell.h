//
//  EventCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLEvent;

@interface EventCell : UITableViewCell

@property UIImageView *userPortrait;
@property UILabel *eventDescription;
@property UITextView *eventAbstract;
@property UILabel *time;

- (void)generateEventDescriptionView:(GLEvent *)event;

@end
