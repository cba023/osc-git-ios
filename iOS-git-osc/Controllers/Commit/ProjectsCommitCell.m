//
//  ProjectsMemberCell.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/27.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "ProjectsCommitCell.h"
#import "Tools.h"
#import "UIColor+Util.h"
#import "UIImageView+Util.h"

@implementation ProjectsCommitCell

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
    _memberImageView = [UIImageView new];
    _memberImageView.layer.cornerRadius = 5;
    _memberImageView.clipsToBounds = YES;
    _memberImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_memberImageView];
    
    _nameLabel = [UILabel new];
    _nameLabel.backgroundColor = [UIColor uniformColor];
    _nameLabel.font = [UIFont boldSystemFontOfSize:14];
    _nameLabel.textColor = [UIColor colorWithHex:0x294fa1];
    [self.contentView addSubview:_nameLabel];
    
    _contentLabel = [UILabel new];
    _contentLabel.backgroundColor = [UIColor uniformColor];
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = [UIFont systemFontOfSize:14];
    _contentLabel.textColor = [UIColor colorWithHex:0x515151];
    [self.contentView addSubview:_contentLabel];
    
    _createtimeLabel = [UILabel new];
    _createtimeLabel.backgroundColor = [UIColor uniformColor];
    _createtimeLabel.textAlignment = NSTextAlignmentLeft;
    _createtimeLabel.font = [UIFont systemFontOfSize:12];
    _createtimeLabel.textColor = [UIColor colorWithHex:0xb6b6b6];
    [self.contentView addSubview:_createtimeLabel];
}

- (void)setLayout
{
    for (UIView *view in [self.contentView subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_memberImageView, _nameLabel, _contentLabel, _createtimeLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_memberImageView(36)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_nameLabel]-5-[_contentLabel]-5-[_createtimeLabel]"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_memberImageView(36)]-8-[_nameLabel]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

- (void)contentForProjectsCommit:(GLCommit *)commit
{
    [_memberImageView loadPortrait:[NSURL URLWithString:commit.author.portrait]];
    _nameLabel.text = commit.authorName;
    _contentLabel.text = commit.title;
    _createtimeLabel.attributedText = [Tools getIntervalAttrStr:commit.createdAtString];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
