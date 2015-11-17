//
//  CreationInfoCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "CreationInfoCell.h"

@implementation CreationInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubviews];
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

#pragma mark - Subviews and Layout

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_portrait];
    
    _creationInfo = [UILabel new];
    [_creationInfo setFont:[UIFont systemFontOfSize:13]];
    [self.contentView addSubview:_creationInfo];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.contentView subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(25)]-[_creationInfo]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_portrait, _creationInfo)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait(25)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_portrait)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_creationInfo]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_creationInfo)]];
}


@end
