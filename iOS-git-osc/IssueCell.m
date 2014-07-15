//
//  IssueCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssueCell.h"

@implementation IssueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor *bgColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
        self.contentView.backgroundColor = bgColor;
        
        UIImageView *userPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(6, 4, 36, 36)];
        userPortrait.contentMode = UIViewContentModeScaleAspectFit;
        //[self.contentView addSubview:userPortrait];
        
        _title = [[RTLabel alloc] initWithFrame:CGRectMake(59, 0, 262, 21)];
        _title.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_title];
        
        _description = [[RTLabel alloc] initWithFrame:CGRectMake(59, 20, 262, 21)];
        [self.contentView addSubview:_description];
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
