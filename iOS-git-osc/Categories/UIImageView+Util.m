//
//  UIImageView+Util.m
//  zbapp
//
//  Created by AeternChan on 6/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "UIImageView+Util.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (Util)

- (void)loadPortrait:(NSURL *)portraitURL
{
    [self sd_setImageWithURL:portraitURL placeholderImage:[UIImage imageNamed:@"portrait_loading"] options:0];
}

@end
