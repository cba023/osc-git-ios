//
//  EventCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "EventCell.h"
#import "GLEvent.h"
#import "Event.h"
#import "Tools.h"

@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [Tools uniformColor];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self initSubview];
        [self setAutoLayout];
        
        UIView *selectedBackground = [UIView new];
        selectedBackground.backgroundColor = UIColorFromRGB(0xdadbdc);
        [self setSelectedBackgroundView:selectedBackground];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - init
- (void)initSubview
{
    self.backgroundColor = [UIColor clearColor];
    
    _userPortrait = [UIImageView new];
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_userPortrait];
    
    _eventDescription = [UILabel new];
    _eventDescription.backgroundColor = [Tools uniformColor];
    _eventDescription.numberOfLines = 0;
    _eventDescription.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:_eventDescription];
    
    _eventAbstract = [UITextView new];
    _eventAbstract.backgroundColor = [Tools uniformColor];
    [Tools roundView:_eventAbstract cornerRadius:3.0];
    //_eventAbstract.backgroundColor = [UIColor whiteColor];
    //_eventAbstract.selectable = NO;
    _eventAbstract.editable = NO;
    _eventAbstract.scrollEnabled = NO;
    [self.contentView addSubview:_eventAbstract];
    
    _time = [UILabel new];
    _time.backgroundColor = [Tools uniformColor];
    [self.contentView addSubview:_time];
}

- (void)setAutoLayout
{
    for (UIView *subview in [self.contentView subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_userPortrait, _eventDescription, _eventAbstract, _time);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_userPortrait(36)]-8-[_eventDescription]-8-|"
                                                                             options:NSLayoutFormatAlignAllTop
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_eventDescription]-5-[_eventAbstract]-5-[_time]-8-|"
                                                                             options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userPortrait(36)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];
}

#pragma mark - 初始化子视图
- (void)generateEventDescriptionView:(GLEvent *)event
{
    [_eventDescription setAttributedText:[Event getEventDescriptionForEvent:event]];
}

@end
