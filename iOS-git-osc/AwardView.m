//
//  AwardView.m
//  Git@OSC
//
//  Created by chenhaoxiang on 14-9-22.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "AwardView.h"
#import "UIImageView+WebCache.h"

@implementation AwardView

- (id)init
{
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        
        _image = [UIImageView new];
        [self addSubview:_image];
        
        _messageLabel = [UILabel new];
        _messageLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_messageLabel];
        
        [self setLayout];
    }
    
    return self;
}

- (void)setLayout
{
    for (UIView *subview in [self subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_image, _messageLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_image(100)]-15-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDict]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[_image(100)]-20-[_messageLabel]-8-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:viewsDict]];
}

- (void)setMessage:(NSString *)message andImageURL:(NSString *)imageURL
{
    [_image sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    _messageLabel.text = message;
}

@end
