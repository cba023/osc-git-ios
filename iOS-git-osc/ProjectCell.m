//
//  ProjectCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-2.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectCell.h"

@implementation ProjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIColor *bgColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
        self.contentView.backgroundColor = bgColor;
        // 适配屏幕
        
        _portrait = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 36, 36)];
        _portrait.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_portrait];
        
        self.projectNameField = [[UILabel alloc] initWithFrame:CGRectMake(54, 0, 167, 21)];
        self.projectNameField.textAlignment = NSTextAlignmentLeft;
        self.projectNameField.font = [UIFont boldSystemFontOfSize:13];
        [self.contentView addSubview:self.projectNameField];
        
        self.projectDescriptionField = [[UILabel alloc] initWithFrame:CGRectMake(54, 20, 252, 21)];
        self.projectDescriptionField.textAlignment = NSTextAlignmentLeft;
        self.projectDescriptionField.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.projectDescriptionField];
#if 0
        UIImageView *languageImage = [[UIImageView alloc] initWithFrame:CGRectMake(13, 42, 15, 15)];
        languageImage.contentMode = UIViewContentModeScaleAspectFit;
        [languageImage setImage:[UIImage imageNamed:@"language"]];
        [self.contentView addSubview:languageImage];
#endif
        
        UIImageView *forkImage = [[UIImageView alloc] initWithFrame:CGRectMake(54, 42, 15, 15)];
        forkImage.contentMode = UIViewContentModeScaleAspectFit;
        [forkImage setImage:[UIImage imageNamed:@"fork"]];
        [self.contentView addSubview:forkImage];
        
        UIImageView *starImage = [[UIImageView alloc] initWithFrame:CGRectMake(145, 42, 15, 15)];
        starImage.contentMode = UIViewContentModeScaleAspectFit;
        [starImage setImage:[UIImage imageNamed:@"star2"]];
        [self.contentView addSubview:starImage];
        
        self.languageField = [[UILabel alloc] initWithFrame:CGRectMake(238, 0, 62, 21)];
        self.languageField.textAlignment = NSTextAlignmentLeft;
        self.languageField.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.languageField];
        
        self.forksCount = [[UILabel alloc] initWithFrame:CGRectMake(77, 39, 43, 21)];
        self.forksCount.textAlignment = NSTextAlignmentLeft;
        self.forksCount.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.forksCount];
        
        self.starsCount = [[UILabel alloc] initWithFrame:CGRectMake(168, 39, 43, 21)];
        self.starsCount.textAlignment = NSTextAlignmentLeft;
        self.starsCount.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.starsCount];
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
