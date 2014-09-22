//
//  AwardView.h
//  Git@OSC
//
//  Created by chenhaoxiang on 14-9-22.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AwardView : UIView

@property UIImageView *image;
@property UILabel *messageLabel;

- (void)setMessage:(NSString *)message andImageURL:(NSString *)imageURL;

@end
