//
//  IssueCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssueCell.h"
#import "Tools.h"

@implementation IssueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [Tools uniformColor];
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

    _title  = [UILabel new];
    _title.backgroundColor = [Tools uniformColor];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    [_title setFont:[UIFont systemFontOfSize:16]];
    [_title setPreferredMaxLayoutWidth:200];
    [self.contentView addSubview:_title];
    
    _issueInfo = [UILabel new];
    _issueInfo.backgroundColor = [Tools uniformColor];
    [_issueInfo setFont:[UIFont systemFontOfSize:10]];
    [self.contentView addSubview:_issueInfo];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.contentView subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_portrait, _title, _issueInfo);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_title]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]" options:0 metrics:nil views:viewsDictionary]];
     
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[_title]-8-[_issueInfo]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}


@end
