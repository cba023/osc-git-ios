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
        [self initSubview];
        [self setAutoLayout];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.eventDescription.preferredMaxLayoutWidth = CGRectGetWidth(self.eventDescription.frame);
}

#pragma mark - init
- (void)initSubview
{
    UIColor *bgColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
    self.contentView.backgroundColor = bgColor;
    
    _userPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 36, 36)];
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_userPortrait];
    
    _eventDescription = [[UILabel alloc] initWithFrame:CGRectMake(49, 0, 251, 30)];
    [_eventDescription setNumberOfLines:0];
    _eventDescription.textAlignment = NSTextAlignmentLeft;
    //_eventDescription.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.eventDescription];
    
    _time = [[UILabel alloc] initWithFrame:CGRectMake(63, 27, 158, 21)];
    _time.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.time];
}

- (void)setAutoLayout
{
    [_eventDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_time setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_eventDescription]-[_time]-(5)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_eventDescription, _time)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(50)-[_eventDescription]-(5)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_eventDescription)]];
}

@end
