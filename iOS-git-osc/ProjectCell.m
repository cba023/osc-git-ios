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
        self.backgroundColor = [UIColor clearColor];
        
        [self initSubViews];
        [self setLayout];
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
    _projectNameField.textAlignment = NSTextAlignmentLeft;
    _projectNameField.font = [UIFont boldSystemFontOfSize:13];
    [self.contentView addSubview:_projectNameField];
    
    _projectDescriptionField = [UILabel new];
    _projectDescriptionField.textAlignment = NSTextAlignmentLeft;
    _projectDescriptionField.font = [UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:_projectDescriptionField];
    
    _languageField = [UILabel new];
    _languageField.textAlignment = NSTextAlignmentLeft;
    _languageField.font = [UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:_languageField];
    
    _forksCount = [UILabel new];
    _forksCount.textAlignment = NSTextAlignmentLeft;
    _forksCount.font = [UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:_forksCount];
    
    _starsCount = [UILabel new];
    _starsCount.textAlignment = NSTextAlignmentLeft;
    _starsCount.font = [UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:_starsCount];

}

- (void)setLayout
{
    UIImageView *languageImage = [UIImageView new];
    languageImage.contentMode = UIViewContentModeScaleAspectFit;
    [languageImage setImage:[UIImage imageNamed:@"language"]];
    [self.contentView addSubview:languageImage];
    
    UIImageView *forkImage = [[UIImageView alloc] initWithFrame:CGRectMake(54, 42, 15, 15)];
    forkImage.contentMode = UIViewContentModeScaleAspectFit;
    [forkImage setImage:[UIImage imageNamed:@"fork"]];
    [self.contentView addSubview:forkImage];
    
    UIImageView *starImage = [[UIImageView alloc] initWithFrame:CGRectMake(145, 42, 15, 15)];
    starImage.contentMode = UIViewContentModeScaleAspectFit;
    [starImage setImage:[UIImage imageNamed:@"star2"]];
    [self.contentView addSubview:starImage];

    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_projectNameField]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_portrait, _projectNameField)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_projectNameField]-3-[_projectDescriptionField]-5-[languageImage]"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_projectNameField, _projectDescriptionField, languageImage)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[languageImage(15)][_languageField]-10-[forkImage(15)][_forksCount]-10-[starImage(15)][_starsCount]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(languageImage, _languageField, forkImage, _forksCount, starImage, _starsCount)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_projectDescriptionField]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_projectDescriptionField)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_portrait(36)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_portrait)]];
    
#if 0
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[languageImage(==15==forkImage, ==starImage)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(languageImage, forkImage, starImage)]];
#endif
}


@end
