//
//  NoteCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "NoteCell.h"

@implementation NoteCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubviews];
        [self setAutoLayout];
        
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

#pragma mark - Subviews and Layout

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_portrait];
    
    _author = [UILabel new];
    [_author setFont:[UIFont systemFontOfSize:12]];
    [self.contentView addSubview:_author];
    
    _body = [UITextView new];
    _body.backgroundColor = [UIColor clearColor];
    _body.editable = NO;
    //_body.selectable = NO;
    _body.scrollEnabled = NO;
    [self.contentView addSubview:_body];
    
    _time = [UILabel new];
    [_time setFont:[UIFont systemFontOfSize:10]];
    [self.contentView addSubview:_time];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.contentView subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[_portrait(25)]-(8)-[_author]-[_time]-(8)-|"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_portrait, _author, _time)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[_portrait(25)]-(5)-[_body]-(5)-|"
                                                                             options:NSLayoutFormatAlignAllLeft
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_portrait, _body)]];
    
#if 1
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_body]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_body)]];
    
#else
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_time]-[_body]"
                                                                             options:NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_time, _body)]];
#endif
}


@end
