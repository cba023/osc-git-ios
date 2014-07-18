//
//  EventCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "EventCell.h"

@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor *bgColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
        self.contentView.backgroundColor = bgColor;
        
        _userPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 36, 36)];
        _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_userPortrait];

        CGFloat width = 251;
        CGSize size = [_eventDescription sizeThatFits:CGSizeMake(width, FLT_MAX)];
        _eventDescription = [[UILabel alloc] initWithFrame:CGRectMake(49, 0, width, size.height)];
        _eventDescription.textAlignment = NSTextAlignmentLeft;
        //_eventDescription.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.eventDescription];
        
        _time = [[UILabel alloc] initWithFrame:CGRectMake(63, 27, 158, 21)];
        _time.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.time];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
