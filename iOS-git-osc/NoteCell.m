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
    
    _body = [UIWebView new];
    _body.scrollView.scrollEnabled = NO;
    _body.scrollView.bounces = NO;
    _body.opaque = NO;
    _body.backgroundColor = [UIColor clearColor];
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
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_time]-[_body]"
                                                                             options:NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_time, _body)]];
}


@end
