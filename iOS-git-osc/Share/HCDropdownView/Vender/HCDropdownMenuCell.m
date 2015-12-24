//
//  HCDropdownMenuCell.m
//  DropDown
//
//  Created by Holden on 15/11/4.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "HCDropdownMenuCell.h"

@implementation HCDropdownMenuCell

- (void)awakeFromNib {
    _titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
