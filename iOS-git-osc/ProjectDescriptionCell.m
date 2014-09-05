//
//  ProjectDescriptionCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectDescriptionCell.h"
#import "Tools.h"

@implementation ProjectDescriptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (id)initWithStarsCount:(NSInteger)starsCount
            watchesCount:(NSInteger)watchesCount
               isStarred:(BOOL)isStarred
               isWatched:(BOOL)isWatched
             description:(NSString *)projectDescription
{
    self = [super init];
    if (self) {
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self initSubviews];
        [self setLayout];
        
        _isStarred = isStarred;
        _isWatched = isWatched;
        [_starButton setTitle:[NSString stringWithFormat:@" Star %d ", starsCount] forState:UIControlStateNormal];
        [_watchButton setTitle:[NSString stringWithFormat:@" Watch %d ", watchesCount] forState:UIControlStateNormal];
        _projectDescriptionField.text = projectDescription;
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
    _projectDescriptionField = [UILabel new];
    _projectDescriptionField.lineBreakMode = NSLineBreakByWordWrapping;
    _projectDescriptionField.numberOfLines = 0;
    _projectDescriptionField.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_projectDescriptionField];
    
    _starButton = [UIButton new];
    //[_starButton setImage:[UIImage imageNamed:@"projectCellStar"] forState:UIControlStateNormal];
    _starButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_starButton setBackgroundColor:[UIColor grayColor]];
    [Tools roundView:_starButton cornerRadius:2.0];
    [self.contentView addSubview:_starButton];
    
    _watchButton = [UIButton new];
    _watchButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [_watchButton setBackgroundColor:[UIColor grayColor]];
    //[_watchButton setImage:[UIImage imageNamed:@"projectCellWatch"] forState:UIControlStateNormal];
    [Tools roundView:_watchButton cornerRadius:2.0];
    [self.contentView addSubview:_watchButton];
}

- (void)setLayout
{
    for (UIView *subview in [self.contentView subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_projectDescriptionField]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_projectDescriptionField)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_projectDescriptionField]-8-[_watchButton(25)]-8-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_projectDescriptionField, _watchButton)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_starButton]-15-[_watchButton]-20-|"
                                                                             options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_starButton, _watchButton)]];
}


@end
