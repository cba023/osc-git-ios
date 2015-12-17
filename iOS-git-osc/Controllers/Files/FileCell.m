//
//  FileCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "FileCell.h"
#import "Tools.h"

@implementation FileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [Tools uniformColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

        [self setLayout];
        
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

- (void)setLayout
{
    _fileType = [UIImageView new];
    _fileType.contentMode = UIViewContentModeScaleAspectFill;
    _fileType.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_fileType];
    
    _fileName = [UILabel new];
    _fileName.backgroundColor = [Tools uniformColor];
    _fileName.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_fileName];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_fileType, _fileName);
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_fileType]-15-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_fileType]-[_fileName]"
                                                                             options:NSLayoutFormatAlignAllCenterY
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

@end
