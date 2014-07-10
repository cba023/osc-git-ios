//
//  EventCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "EventCell.h"
#import "GLEvent.h"

@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
#if 0
        UIColor *bgColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
        self.contentView.backgroundColor = bgColor;
        // 适配屏幕
        self.fileType = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 15, 15)];
        self.fileType.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.fileType];
        
        self.fileName = [[UILabel alloc] initWithFrame:CGRectMake(33, 4, 310, 21)];
        self.fileName.textAlignment = NSTextAlignmentLeft;
        self.fileName.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.fileName];
#endif
        UIImageView *userPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(6, 4, 36, 36)];
        userPortrait.contentMode = UIViewContentModeScaleAspectFit;
        //[self.contentView addSubview:userPortrait];
        
        self.eventDescription = [[RTLabel alloc] initWithFrame:CGRectMake(59, 7, 262, 29)];
        _eventDescription.textAlignment = NSTextAlignmentLeft;
        _eventDescription.font = [UIFont systemFontOfSize:12];
        
        [self.contentView addSubview:self.eventDescription];
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
