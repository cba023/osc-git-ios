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
    [_projectDescriptionField setPreferredMaxLayoutWidth:200];
    [self.contentView addSubview:_projectDescriptionField];
    
    _lSFWLabel = [UILabel new];
    _lSFWLabel.backgroundColor = [Tools uniformColor];
    _lSFWLabel.textAlignment = NSTextAlignmentLeft;
    _lSFWLabel.font = [UIFont systemFontOfSize:12];
    _lSFWLabel.textColor = UIColorFromRGB(0xb6b6b6);
    [self.contentView addSubview:_lSFWLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_portrait, _projectNameField, _projectDescriptionField, _lSFWLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_projectNameField]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_projectNameField(15)]-8-[_projectDescriptionField]-8@999-[_lSFWLabel(16)]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_projectNameField]-5-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

- (void)contentForProjects:(GLProject *)project
{
    [Tools setPortraitForUser:project.owner view:self.portrait cornerRadius:5.0];
    self.projectNameField.attributedText = project.attributedProjectName;
//    self.projectNameField.text = [NSString stringWithFormat:@"%@ / %@", project.owner.name, project.name];
    self.projectDescriptionField.text = project.projectDescription.length > 0? project.projectDescription: @"暂无项目介绍";
    self.lSFWLabel.attributedText = project.attributedLanguage;
}


@end
