//
//  Tools.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ProjectsTypeFeatured = 0,
    ProjectsTypePopular,
    ProjectsTypeLatest,
    ProjectsTypeEventForUser,
    ProjectsTypeStared,
    ProjectsTypeWatched,
    ProjectsTypeLanguage,
    ProjectsTypeSearch,
    ProjectsTypeUserProjects,
} ProjectsType;


@class GLUser;
@class GLEvent;
@class GLIssue;

@interface Tools : NSObject

+ (NSString *)getPrivateToken;

+ (NSString *)md5:(NSString *)input;
+ (UIImage *)loadImage:(NSString *)imageURL;

+ (NSString *)escapeHTML:(NSString *)string;
+ (NSString *)flattenHTML:(NSString *)html;
+ (BOOL)isEmptyString:(NSString *)string;

+ (NSString *)intervalSinceNow:(NSString *)dateStr;
+ (NSAttributedString *)getIntervalAttrStr:(NSString *)dateStr;

+ (NSAttributedString *)grayString:(NSString *)string fontName:(NSString *)fontName fontSize:(CGFloat)size;
+ (void)roundView:(UIView *)view cornerRadius:(CGFloat)cornerRadius;
+ (void)setPortraitForUser:(GLUser *)user view:(UIImageView *)portraitView cornerRadius:(CGFloat)cornerRadius;
+ (UIColor *)uniformColor;
+ (UIImage *)getScreenshot:(UIView *)view;

+ (void)toastNotification:(NSString *)text inView:(UIView *)view;
+ (NSInteger)networkStatus;
+ (BOOL)isNetworkExist;

+ (BOOL)isPageCacheExist:(ProjectsType)type;
+ (NSArray *)getPageCache:(ProjectsType)type;
+ (void)savePageCache:(NSArray *)page type:(ProjectsType)type;

+ (NSUInteger)numberOfRepeatedEvents:(NSArray *)events event:(GLEvent *)event;
+ (NSUInteger)numberOfRepeatedIssueds:(NSArray *)issues issue:(GLIssue *)issue;
#pragma mark - 判断是否有网络
+ (BOOL)isConnectionAcailable;
+ (NSData *)compressImage:(UIImage *)image;

@end
