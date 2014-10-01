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
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userInteractionEnabled = YES;
        [self initSubviews];
        [self setLayout];
        
        _isStarred = isStarred;
        _isWatched = isWatched;
        NSString *starAction = isStarred? @"Unstar" : @"Star";
        NSString *watchAction = isWatched? @"Unwatch" : @"Watch";
        
        [_starButton setTitle:[NSString stringWithFormat:@" %@ %ld ",starAction, (long)starsCount] forState:UIControlStateNormal];
        NSString *starImageName = isStarred? @"projectDetails_star" : @"projectDetails_unstar";
        [_starButton setImage:[UIImage imageNamed:starImageName] forState:UIControlStateNormal];
        [_starButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, -1)];
        
        [_watchButton setTitle:[NSString stringWithFormat:@" %@ %ld ",watchAction, (long)watchesCount] forState:UIControlStateNormal];
        NSString *watchImageName = isWatched? @"projectDetails_watch" : @"projectDetails_unwatch";
        [_watchButton setImage:[UIImage imageNamed:watchImageName] forState:UIControlStateNormal];
        [_watchButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, -1)];
        
        _projectDescriptionField.text = projectDescription.length > 0? projectDescription : @"暂无项目介绍";
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
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_projectDescriptionField]-8-[_watchButton(27)]-8-|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:NSDictionaryOfVariableBindings(_projectDescriptionField, _watchButton)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_starButton]-15-[_watchButton]-20-|"
                                                                             options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_starButton, _watchButton)]];
}




@end
