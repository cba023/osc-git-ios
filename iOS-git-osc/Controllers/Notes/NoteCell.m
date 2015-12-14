//
//  NoteCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "NoteCell.h"
#import "Tools.h"
#import "UIColor+Util.h"
#import "UIImageView+Util.h"

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
    [_author setFont:[UIFont systemFontOfSize:15]];
    [self.contentView addSubview:_author];
    
    _body = [UILabel new];
    _body.backgroundColor = [UIColor clearColor];
    _body.numberOfLines = 0;
    _body.font = [UIFont systemFontOfSize:16];
    _body.lineBreakMode = NSLineBreakByWordWrapping;
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
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[_portrait(25)]-(13)-[_body]-(8)-|"
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

- (void)contentForProjectsComment:(GLComment *)comment
{
    [Tools setPortraitForUser:comment.author view:_portrait cornerRadius:2.0];
    _author.text = comment.author.name;
    _body.text = [Tools flattenHTML:comment.noteString];
    _time.attributedText = [Tools getIntervalAttrStr:comment.creatTime];
}


@end
