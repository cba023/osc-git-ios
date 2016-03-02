//
//  Tools.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Tools.h"
#import "GLGitlab.h"
#import "GLGitlabApi+Private.h"
#import <CommonCrypto/CommonDigest.h>
#import "UIImageView+WebCache.h"
#import "Reachability.h"
#import "UIView+Toast.h"
#import "GITAPI.h"

#import "UIImageView+Util.h"

@implementation Tools

+ (NSString *)getPrivateToken
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [userDefaults stringForKey:@"private_token"];
    if  (!privateToken) {
        privateToken = @"";
    }
    return privateToken;
}

+ (NSString *) md5: (NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  [NSString stringWithString: output];
}

+ (UIImage *)loadImage:(NSString *)urlString {
    NSURL *imageURL = [NSURL URLWithString:urlString];
    __block UIImage *img = [[UIImage alloc] init];

    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:imageURL
                                                          options:0
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             
                                                         }
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            if (image && finished) {
                                                                img = image;
                                                            }
                                                        }];

    return img;
}


#pragma mark - about string

+ (NSString *)escapeHTML:(NSString *)originalHTML
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:originalHTML];
	[result replaceOccurrencesOfString:@"&"  withString:@"&amp;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"<"  withString:@"&lt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@">"  withString:@"&gt;"   options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"'"  withString:@"&#39;"  options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	return result;
}

+ (NSString *)flattenHTML:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
    theScanner = [NSScanner scannerWithString: html];
    while ([theScanner isAtEnd] == NO) {
        // find start of tag
        [theScanner scanUpToString: @"<" intoString: NULL];
        // find end of tag
        [theScanner scanUpToString: @">" intoString: &text];
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat: @"%@>", text]
                                               withString: @""];
    } // while //
    return html;
}

+ (BOOL)isEmptyString:(NSString *)string
{
    if (!string || string.length == 0) {return YES;}
    NSMutableString *temp = [[NSMutableString alloc] initWithString:[string stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [temp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return [temp isEqualToString:@""];
}

#pragma mark - 时间间隔显示
+ (NSString *)intervalSinceNow:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *compsPast = [calendar components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger years = [compsNow year] - [compsPast year];
    NSInteger months = [compsNow month] - [compsPast month] + years * 12;
    NSInteger days = [compsNow day] - [compsPast day] + months * 30;
    NSInteger hours = [compsNow hour] - [compsPast hour] + days * 24;
    NSInteger minutes = [compsNow minute] - [compsPast minute] + hours * 60;
    
    if (minutes < 1) {
        return @"刚刚";
    } else if (minutes < 60) {
        return [NSString stringWithFormat:@"%ld 分钟前", (long)minutes];
    } else if (hours < 24) {
        return [NSString stringWithFormat:@"%ld 小时前", (long)hours];
    } else if (hours < 48 && days == 1) {
        return @"昨天";
    } else if (days < 30) {
        return [NSString stringWithFormat:@"%ld 天前", (long)days];
    } else if (days < 60) {
        return @"一个月前";
    } else if (months < 12) {
        return [NSString stringWithFormat:@"%ld 个月前", (long)months];
    } else {
        NSArray *arr = [dateStr componentsSeparatedByString:@"T"];
        return [arr objectAtIndex:0];
    }
}

+ (NSAttributedString *)getIntervalAttrStr:(NSString *)dateStr
{
    NSAttributedString *intervalAttrStr = [self grayString:[self intervalSinceNow:dateStr]
                                                  fontName:nil
                                                  fontSize:12];
    
    return intervalAttrStr;
}

#pragma mark - UI thing

+ (NSAttributedString *)grayString:(NSString *)string fontName:(NSString *)fontName fontSize:(CGFloat)size
{
    UIFont *font;
    if (fontName) {
        font = [UIFont fontWithName:fontName size:size];
    } else {
        font = [UIFont systemFontOfSize:size];
    }

    UIColor *grayColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    NSAttributedString *grayString = [[NSAttributedString alloc] initWithString:string
                                                                     attributes:@{NSFontAttributeName:font,
                                                                                  NSForegroundColorAttributeName:grayColor}];
    
    return grayString;
}

+ (void)roundView:(UIView *)view cornerRadius:(CGFloat)cornerRadius
{
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

+ (void)setPortraitForUser:(GLUser *)user view:(UIImageView *)portraitView cornerRadius:(CGFloat)cornerRadius
{
    NSString *portraitURL = [NSString stringWithString:user.portrait];
    
    [portraitView loadPortrait:[NSURL URLWithString:portraitURL]];
    
    [self roundView:portraitView cornerRadius:cornerRadius];
}

+ (UIColor *)uniformColor
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}

+ (UIImage *)getScreenshot:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);

    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
#if 1
    UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
#else
    if(UIGraphicsBeginImageContextWithOptions != NULL) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0);
    } else {
        UIGraphicsBeginImageContext(view.frame.size);
    }
#endif

    UIGraphicsEndImageContext();

    return screenshot;
}


#pragma mark - about notifications
+ (void)toastNotification:(NSString *)text inView:(UIView *)view
{
    [view makeToast:text duration:2.0 position:@"center"];
}

+ (NSInteger)networkStatus
{
    NSString *httpStr = [GITAPI_HTTPS_PREFIX componentsSeparatedByString:@"/api/v3/"][0];
    httpStr = [httpStr componentsSeparatedByString:@"//"][1];
    
    Reachability *reach = [Reachability reachabilityWithHostName:httpStr];
    return [reach currentReachabilityStatus];
}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] > 0;
}

+ (BOOL)isPageCacheExist:(ProjectsType)type
{
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSArray *cachePage = [cache arrayForKey:[NSString stringWithFormat:@"type-%ld", (long)type]];
    
    return cachePage != nil;
}

+ (NSArray *)getPageCache:(ProjectsType)type
{
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    //NSArray *cachePage = [cache arrayForKey:[NSString stringWithFormat:@"type-%ld", (long)type]];
    NSArray *cachePage = [cache objectForKey:[NSString stringWithFormat:@"type-%ld", (long)type]];
    
    Class class;
    if (type < 9) {
        class = [GLProject class];
    } else if (type == 9) {
        class = [GLEvent class];
    } else {
        class = [GLLanguage class];
    }
    
    NSArray *page = [[GLGitlabApi sharedInstance] processJsonArray:cachePage class:class];
    
    return page;
}

+ (void)savePageCache:(NSArray *)page type:(ProjectsType)type
{
    NSMutableArray *jsonCache = [NSMutableArray arrayWithCapacity:page.count];
    NSString *key = [NSString stringWithFormat:@"type-%ld", (long)type];
    for (GLBaseObject *glObject in page) {
        NSDictionary *jsonRep = [glObject jsonRepresentation];
        [jsonCache addObject:jsonRep];
    }
    
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    if ([cache objectForKey:key]) {[cache removeObjectForKey:key];}
    [cache setObject:jsonCache forKey:key];
}

+ (NSUInteger)numberOfRepeatedEvents:(NSArray *)events event:(GLEvent *)event
{
    NSUInteger len = [events count];
    GLEvent *eventInArray;
    for (NSUInteger i = 1; i <= len; i++) {
        eventInArray = [events objectAtIndex:len-i];
        if (eventInArray.eventID == event.eventID) {
            return i;
        }
    }
    
    return 0;
}

+ (NSUInteger)numberOfRepeatedIssueds:(NSArray *)issues issue:(GLIssue *)issue
{
    NSUInteger len = [issues count];
    GLIssue *issueInArray;
    for (NSUInteger i = 1; i <= len; i++) {
        issueInArray = [issues objectAtIndex:len-i];
        if (issueInArray.issueId == issue.issueId) {
            return i;
        }
    }
    
    return 0;
}

#pragma mark - 判断是否有网络
+ (BOOL)isConnectionAcailable
{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:GITAPI_HTTPS_PREFIX];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;//wifi
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;//3G
            break;
            
        default:
            break;
    }
    
    return isExistenceNetwork;
}

#pragma mark - 处理图片
+ (NSData *)compressImage:(UIImage *)image
{
    CGSize size = [self scaleSize:image.size];
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSUInteger maxFileSize = 500 * 1024;
    CGFloat compressionRatio = 0.7f;
    CGFloat maxCompressionRatio = 0.1f;
    
    NSData *imageData = UIImageJPEGRepresentation(scaledImage, compressionRatio);
    
    while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
        compressionRatio -= 0.1f;
        imageData = UIImageJPEGRepresentation(image, compressionRatio);
    }
    
    return imageData;
}

+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    } else {
        return CGSizeMake(800 * width / height, 800);
    }
}

@end
