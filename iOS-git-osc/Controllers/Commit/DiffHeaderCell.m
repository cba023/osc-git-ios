//
//  DiffHeaderCell.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/2.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "DiffHeaderCell.h"
#import "Tools.h"
#import "UIColor+Util.h"
#import "UIImageView+Util.h"

@implementation DiffHeaderCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor uniformColor];
        
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubViews];
        [self setLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = [UIColor colorWithHex:0xdadbdc];
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)initSubViews
{
    _portrait = [UIImageView new];
    _portrait.layer.cornerRadius = 5;
    _portrait.clipsToBounds = YES;
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_portrait];
    
    _committerLabel = [UILabel new];
    _committerLabel.font = [UIFont systemFontOfSize:14];
    _committerLabel.textColor = [UIColor colorWithHex:0x294fa1];
    [_committerLabel setPreferredMaxLayoutWidth:200];
    [self.contentView addSubview:_committerLabel];
    
    _timeLabel = [UILabel new];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textColor = [UIColor colorWithHex:0xb6b6b6];
    [self.contentView addSubview:_timeLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.font = [UIFont boldSystemFontOfSize:16];
    _contentLabel.textColor = [UIColor colorWithHex:0x515151];
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    _contentLabel.numberOfLines = 4;
    [self.contentView addSubview:_contentLabel];
    

}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_contentLabel, _portrait, _committerLabel, _timeLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_committerLabel]-6-[_timeLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_timeLabel]-6-[_contentLabel]-8-|"
                                                                             options:NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-8-[_committerLabel]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_contentLabel]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

- (void)contentForProjectsCommit:(GLCommit *)commit
{
    [_portrait loadPortrait:[NSURL URLWithString:commit.author.portrait]];
    _committerLabel.text = commit.authorName;
    _contentLabel.text = commit.title;
    _timeLabel.attributedText = [Tools getIntervalAttrStr:commit.createdAtString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
