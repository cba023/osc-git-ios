//
//  ProjectCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-2.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectCell.h"
#import "Tools.h"

@implementation ProjectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [Tools uniformColor];
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubViews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = UIColorFromRGB(0xdadbdc);
        [self setSelectedBackgroundView:selectedBackground];
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

- (void)initSubViews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_portrait];
    
    _projectNameField = [UILabel new];
    _projectNameField.backgroundColor = [Tools uniformColor];
    _projectNameField.font = [UIFont boldSystemFontOfSize:14];
    _projectNameField.textColor = UIColorFromRGB(0x294fa1);
    [self.contentView addSubview:_projectNameField];
    
    _projectDescriptionField = [UILabel new];
    _projectDescriptionField.backgroundColor = [Tools uniformColor];
    _projectDescriptionField.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    _projectDescriptionField.numberOfLines = 4;
    _projectDescriptionField.font = [UIFont systemFontOfSize:14];
    _projectDescriptionField.textColor = UIColorFromRGB(0x515151);
    [self.contentView addSubview:_projectDescriptionField];
    
    _languageField = [UILabel new];
    _languageField.backgroundColor = [Tools uniformColor];
    _languageField.textAlignment = NSTextAlignmentLeft;
    _languageField.font = [UIFont systemFontOfSize:12];
    _languageField.textColor = UIColorFromRGB(0xb6b6b6);
    [self.contentView addSubview:_languageField];
    
    _forksCount = [UILabel new];
    _forksCount.backgroundColor = [Tools uniformColor];
    _forksCount.textAlignment = NSTextAlignmentLeft;
    _forksCount.font = [UIFont boldSystemFontOfSize:12];
    _forksCount.textColor = UIColorFromRGB(0xb6b6b6);
    [self.contentView addSubview:_forksCount];
    
    _starsCount = [UILabel new];
    _starsCount.backgroundColor = [Tools uniformColor];
    _starsCount.textAlignment = NSTextAlignmentLeft;
    _starsCount.font = [UIFont boldSystemFontOfSize:12];
    _starsCount.textColor = UIColorFromRGB(0xb6b6b6);
    [self.contentView addSubview:_starsCount];
}

- (void)setLayout
{
    UIImageView *languageImage = [UIImageView new];
    languageImage.contentMode = UIViewContentModeScaleAspectFit;
    [languageImage setImage:[UIImage imageNamed:@"projectCellLanguage"]];
    [self.contentView addSubview:languageImage];
    
    UIImageView *forkImage = [UIImageView new];
    forkImage.contentMode = UIViewContentModeScaleAspectFit;
    [forkImage setImage:[UIImage imageNamed:@"projectCellFork"]];
    [self.contentView addSubview:forkImage];
    
    UIImageView *starImage = [UIImageView new];
    starImage.contentMode = UIViewContentModeScaleAspectFit;
    [starImage setImage:[UIImage imageNamed:@"projectCellStar"]];
    [self.contentView addSubview:starImage];

    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_portrait, _projectNameField, _projectDescriptionField, languageImage, forkImage, starImage, _languageField, _forksCount, _starsCount);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_projectNameField]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_projectNameField(15)]-8-[_projectDescriptionField]-8@999-[languageImage]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[languageImage(15)][_languageField]-10-[forkImage(15)][_forksCount]-10-[starImage(15)][_starsCount]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_projectDescriptionField]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];

    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[languageImage(15)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[forkImage(==languageImage)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[starImage(==languageImage)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}


@end
