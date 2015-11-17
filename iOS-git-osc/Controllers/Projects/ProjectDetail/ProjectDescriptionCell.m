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
        self.backgroundColor = UIColorFromRGB(0xf0f0f0);
        self.userInteractionEnabled = YES;
        [self initSubviews];
        [self setLayout];
        
        _isStarred = isStarred;
        _isWatched = isWatched;
        NSString *starAction = isStarred? @"Unstar" : @"Star";
        NSString *watchAction = isWatched? @"Unwatch" : @"Watch";
        
        [_starButton setTitle:[NSString stringWithFormat:@" %@",starAction] forState:UIControlStateNormal];
        [_starButton setImage:[UIImage imageNamed:@"projectDetails_star"] forState:UIControlStateNormal];
        [_starButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, -1)];
        _starsCountLabel.text = [NSString stringWithFormat:@"%ld %@", (long)starsCount, starsCount > 1? @"stars" :@"star"];
        
        [_watchButton setTitle:[NSString stringWithFormat:@" %@",watchAction] forState:UIControlStateNormal];
        [_watchButton setImage:[UIImage imageNamed:@"projectDetails_watch"] forState:UIControlStateNormal];
        [_watchButton setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, -1)];
        _watchesCountLabel.text = [NSString stringWithFormat:@"%ld %@", (long)watchesCount, watchesCount > 1? @"watches": @"watch"];
        
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
    _projectDescriptionField.backgroundColor = UIColorFromRGB(0xf0f0f0);
    _projectDescriptionField.lineBreakMode = NSLineBreakByWordWrapping;
    _projectDescriptionField.numberOfLines = 0;
    _projectDescriptionField.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:_projectDescriptionField];
    
    _starsCountLabel = [UILabel new];
    _starsCountLabel.textAlignment = NSTextAlignmentCenter;
    _starsCountLabel.font = [UIFont systemFontOfSize:14];
    _starsCountLabel.textColor = UIColorFromRGB(0x555555);
    _starsCountLabel.backgroundColor = UIColorFromRGB(0xf5f5f5);
    _starsCountLabel.layer.borderWidth = 0.5;
    _starsCountLabel.layer.borderColor = [UIColorFromRGB(0xd4d4d4) CGColor];
    [Tools roundView:_starsCountLabel cornerRadius:5.0];
    [self.contentView addSubview:_starsCountLabel];
    
    _watchesCountLabel = [UILabel new];
    _watchesCountLabel.textAlignment = NSTextAlignmentCenter;
    _watchesCountLabel.font = [UIFont systemFontOfSize:14];
    _watchesCountLabel.textColor = UIColorFromRGB(0x424242);
    _watchesCountLabel.backgroundColor = UIColorFromRGB(0xf5f5f5);
    _watchesCountLabel.layer.borderWidth = 0.5;
    _watchesCountLabel.layer.borderColor = [UIColorFromRGB(0xd4d4d4) CGColor];
    [Tools roundView:_watchesCountLabel cornerRadius:5.0];
    [self.contentView addSubview:_watchesCountLabel];
    
    _starButton = [UIButton new];
    _starButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _starButton.layer.borderWidth = 0.5;
    _starButton.layer.borderColor = [UIColorFromRGB(0xd4d4d4) CGColor];
    [_starButton setTitleColor:UIColorFromRGB(0x494949) forState:UIControlStateNormal];
    [_starButton setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
    [Tools roundView:_starButton cornerRadius:5.0];
    [self.contentView addSubview:_starButton];
    
    _watchButton = [UIButton new];
    _watchButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    _watchButton.layer.borderWidth = 0.5;
    _watchButton.layer.borderColor = [UIColorFromRGB(0xd4d4d4) CGColor];
    [_watchButton setTitleColor:UIColorFromRGB(0x494949) forState:UIControlStateNormal];
    [_watchButton setBackgroundImage:[UIImage imageNamed:@"button_bg"] forState:UIControlStateNormal];
    [Tools roundView:_watchButton cornerRadius:5.0];
    [self.contentView addSubview:_watchButton];
}

- (void)setLayout
{
    for (UIView *subview in [self.contentView subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_projectDescriptionField, _starButton, _watchButton, _starsCountLabel, _watchesCountLabel);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_projectDescriptionField]-8-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_projectDescriptionField]-8-[_starButton(30)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_projectDescriptionField]-30-[_starsCountLabel(35)]-15-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_starsCountLabel(140)]->=8-[_watchesCountLabel(140)]-10-|"
                                                                             options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                             metrics:nil
                                                                               views:viewsDict]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_starButton(140)]->=8-[_watchButton(140)]-10-|"
                                                                             options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
                                                                             metrics:nil
                                                                               views:viewsDict]];
}




@end
