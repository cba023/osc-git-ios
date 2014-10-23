//
//  LastCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-28.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "LastCell.h"
#import "Tools.h"

@implementation LastCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
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

- (id)initCell {
    //self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StatusCell"];
    self = [super init];
    if (self) {
        self.backgroundColor = [Tools uniformColor];
        self.status = LastCellStatusNotVisible;
        
        [self setLayout];
    }
    
    return self;
}

- (void)setLayout
{
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.contentView.bounds.size.width, 20)];
    _statusLabel.backgroundColor = [Tools uniformColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_statusLabel];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.color = [UIColor colorWithRed:54/255 green:54/255 blue:54/255 alpha:1.0];
    _indicator.center = CGPointMake(self.contentView.frame.size.width/2, self.contentView.frame.size.height/2 + 5);
    [self.contentView addSubview:_indicator];
}

- (void)normal
{
    [_indicator stopAnimating];
    _statusLabel.text = @"More...";
    self.userInteractionEnabled = YES;
}

- (void)loading
{
    [_indicator startAnimating];
    _statusLabel.text = @"";
    self.userInteractionEnabled = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)finishedLoad
{
    [_indicator stopAnimating];
    _statusLabel.text = @"全部加载完毕";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


@end
