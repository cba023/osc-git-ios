//
//  ProjectTableCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-6-7.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectTableCell.h"

@implementation ProjectTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor *bgColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
        self.contentView.backgroundColor = bgColor;
        // 适配屏幕
        self.projectNameField = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 156, 20)];
        self.projectNameField.textAlignment = NSTextAlignmentLeft;
        self.projectNameField.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:self.projectNameField];
        
        self.projectDescriptionField = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 310, 21)];
        self.projectDescriptionField.textAlignment = NSTextAlignmentLeft;
        self.projectDescriptionField.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.projectDescriptionField];
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
