//
//  Tools.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLUser;

@interface Tools : NSObject

+ (NSString *)md5:(NSString *)input;
+ (UIImage *)loadImage:(NSString *)imageURL;
+ (NSString *)decodeBase64String:(NSString *)string;

+ (NSString *)intervalSinceNow:(NSString *)dateStr;
+ (NSAttributedString *)getIntervalAttrStr:(NSString *)dateStr;

+ (void)roundCorner:(UIView *)view cornerRadius:(CGFloat)cornerRadius;
+ (void)setPortraitForUser:(GLUser *)user view:(UIImageView *)portraitView cornerRadius:(CGFloat)cornerRadius;

@end
