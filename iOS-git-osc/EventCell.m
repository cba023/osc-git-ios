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
        [self initSubview];
        //[self setAutoLayout];
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

#if 0
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.contentView layoutIfNeeded];
    self.eventDescription.preferredMaxLayoutWidth = CGRectGetWidth(self.eventDescription.frame);
}
#endif

#pragma mark - init
- (void)initSubview
{
    self.backgroundColor = [UIColor clearColor];
    
    _userPortrait = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12, 36, 36)];
    _userPortrait.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:_userPortrait];
    
    _eventDescription = [UITextView new];
    _time = [UILabel new];

#if 0
    _eventDescription = [[UILabel alloc] initWithFrame:CGRectMake(49, 0, 251, 30)];
    [_eventDescription setNumberOfLines:0];
    _eventDescription.textAlignment = NSTextAlignmentLeft;
    //_eventDescription.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.eventDescription];
    
    //_time = [[UILabel alloc] initWithFrame:CGRectMake(63, 27, 158, 21)];
    _time.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.time];
#endif
}

- (void)setAutoLayout
{
    [_eventDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_time setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(5)-[_eventDescription]-[_time]-(5)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_eventDescription, _time)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(50)-[_eventDescription]-(5)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_eventDescription)]];
}

#pragma mark - 初始化子视图
- (void)generateEventDescriptionView:(GLEvent *)event
{
    _eventDescription.frame = CGRectMake(49, 3, 251, 30);
    [_eventDescription setAttributedText:[Event getEventDescriptionForEvent:event]];
    
    CGFloat fixedWidth = _eventDescription.frame.size.width;
    CGSize newSize = [_eventDescription sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = _eventDescription.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    _eventDescription.frame = newFrame;
    
    _eventDescription.backgroundColor = [UIColor clearColor];
    _eventDescription.scrollEnabled = NO;
    _eventDescription.editable = NO;
    _eventDescription.selectable = NO;
    _eventDescription.textAlignment = NSTextAlignmentLeft;
}

- (void)generateEventAbstractView:(GLEvent *)event
{
    NSDictionary *idStrAttributes = @{
                                      NSForegroundColorAttributeName:UIColorFromRGB(0x0d6da8),
                                      NSFontAttributeName:[UIFont systemFontOfSize:14]
                                      };
    NSDictionary *digestAttributes = @{
                                       NSForegroundColorAttributeName:UIColorFromRGB(0x303030),
                                       //NSForegroundColorAttributeName:UIColorFromRGB(0x999999),
                                       NSFontAttributeName:[UIFont systemFontOfSize:14]
                                       };
    NSMutableAttributedString *digest = [NSMutableAttributedString new];
    int totalCommitsCount = [[event.data objectForKey:@"total_commits_count"] intValue];
    
    int digestsCount = 0;
    while (totalCommitsCount > 0) {
        NSString *commitId = [[[[[event data] objectForKey:@"commits"] objectAtIndex:digestsCount] objectForKey:@"id"] substringToIndex:9];
        NSString *message = [[[[event data] objectForKey:@"commits"] objectAtIndex:digestsCount] objectForKey:@"message"];
    
        NSString *commitAuthorName = [[[[event.data objectForKey:@"commits"] objectAtIndex:digestsCount] objectForKey:@"author"] objectForKey:@"name"];
        message = [NSString stringWithFormat:@" %@ - %@", commitAuthorName, message];
        [digest appendAttributedString:[[NSAttributedString alloc] initWithString:commitId attributes:idStrAttributes]];
        [digest appendAttributedString:[[NSAttributedString alloc] initWithString:message attributes:digestAttributes]];
        
        if (++digestsCount == totalCommitsCount || digestsCount >= 2) {break;}
        [digest appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    }
    
    [_eventAbstract setAttributedText:digest];
    //_eventAbstract.selectable = NO;
    _eventAbstract.editable = NO;
    _eventAbstract.scrollEnabled = NO;
}


@end
