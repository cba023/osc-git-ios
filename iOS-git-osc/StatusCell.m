//
//  StatusCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-27.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "StatusCell.h"

@implementation StatusCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setLayout];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStatus:(NSInteger)status {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StatusCell"];
    if (self) {
        self.status = status;
    }
    
    return self;
}

- (void)setLayout
{
    UILabel *statusLabel = [UILabel new];
    statusLabel.text = @"test";
    [self.contentView addSubview:statusLabel];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|->=10-[statusLabel]->=10-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(statusLabel)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=20-[statusLabel]->=20-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(statusLabel)]];
}

@end
