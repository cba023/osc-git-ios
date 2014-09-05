//
//  Tools.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLUser;
@class GLProject;
@class GLEvent;

@interface Tools : NSObject

+ (NSString *)getPrivateToken;

+ (NSString *)md5:(NSString *)input;
+ (UIImage *)loadImage:(NSString *)imageURL;
+ (NSString *)decodeBase64String:(NSString *)originalHTML;

+ (NSString *)escapeHTML:(NSString *)string;
+ (NSString *)flattenHTML:(NSString *)html;
+ (BOOL)isEmptyString:(NSString *)string;

+ (NSString *)intervalSinceNow:(NSString *)dateStr;
+ (NSAttributedString *)getIntervalAttrStr:(NSString *)dateStr;

+ (NSAttributedString *)grayString:(NSString *)string fontName:(NSString *)fontName fontSize:(CGFloat)size;
+ (void)roundView:(UIView *)view cornerRadius:(CGFloat)cornerRadius;
+ (void)setPortraitForUser:(GLUser *)user view:(UIImageView *)portraitView cornerRadius:(CGFloat)cornerRadius;

+ (void)toastNotification:(NSString *)text inView:(UIView *)view;
+ (NSInteger)networkStatus;
+ (BOOL)isNetworkExist;

+ (BOOL)isPageCacheExist:(NSInteger)type;
+ (NSArray *)getPageCache:(NSInteger)type;
+ (void)savePageCache:(NSArray *)page type:(NSInteger)type;

+ (NSUInteger)numberOfRepeatedProjects:(NSArray *)projects project:(GLProject *)project;
+ (NSUInteger)numberOfRepeatedEvents:(NSArray *)events event:(GLEvent *)event;

@end
