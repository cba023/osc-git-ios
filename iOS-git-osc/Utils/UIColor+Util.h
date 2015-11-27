//
//  UIColor+Util.h
//  Git@OSC
//
//  Created by 李萍 on 15/11/23.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Util)

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(int)hexValue;

+ (UIColor *)navigationbarColor;
+ (UIColor *)uniformColor;

@end
