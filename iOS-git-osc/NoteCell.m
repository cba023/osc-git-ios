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
        _author = [[RTLabel alloc] initWithFrame:CGRectMake(10, 0, 269, 20)];
        _author.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_author];
        
        _body = [[RTLabel alloc] initWithFrame:CGRectMake(10, 20, 310, 21)];
        _body.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_body];
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

@end
