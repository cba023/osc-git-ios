//
//  ProjectNameCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-6.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectNameCell.h"
#import "Tools.h"
#import "GLProject.h"

@implementation ProjectNameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithProject:(GLProject *)project {
    self = [super init];
    if (self) {
        _project = project;
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColorFromRGB(0xf0f0f0);
        
        [self initSubviews];
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

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [Tools setPortraitForUser:_project.owner view:_portrait cornerRadius:5.0];
    [self.contentView addSubview:_portrait];
    
    _projectName = [UILabel new];
    _projectName.backgroundColor = UIColorFromRGB(0xf0f0f0);
    [_projectName setText:_project.name];
    _projectName.font = [UIFont boldSystemFontOfSize:17];
    [self.contentView addSubview:_projectName];
    
    _timeInterval = [UILabel new];
    _timeInterval.backgroundColor = UIColorFromRGB(0xf0f0f0);
    NSDictionary *grayTextAttributes = @{
                                         NSForegroundColorAttributeName:[UIColor grayColor],
                                         NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Medium" size:15]
                                         };
    NSMutableAttributedString *updateTime = [[NSMutableAttributedString alloc] initWithString:@"更新于 " attributes:grayTextAttributes];
    NSString *lastPushTime = _project.lastPushAt ?: _project.createdAt;
    [updateTime appendAttributedString:[Tools getIntervalAttrStr:lastPushTime]];
    [_timeInterval setAttributedText:updateTime];
    [self.contentView addSubview:_timeInterval];
}

- (void)setLayout
{
    for (UIView *subview in [self.contentView subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_portrait, _projectName, _timeInterval);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]-[_timeInterval]-8-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-[_projectName]->=8-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait]-[_timeInterval]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}


@end
