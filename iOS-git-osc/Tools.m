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

#pragma mark - 解码base64字符串

+ (NSString *)decodeBase64String:(NSString *)string {
    NSData  *base64Data = [self base64DataFromString:string];
    
    NSString* decryptedStr = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    return decryptedStr;
}

+ (NSData *)base64DataFromString: (NSString *)string {
    if (!string) {
        return [NSData data];
    }
    
    unsigned long ixtext = 0, lentext = [string length];
    unsigned char ch, input[4], output[3];
    short i, ixinput = 0;
    Boolean flignore, flendtext = false;
    const char *temporary = [string UTF8String];
    NSMutableData *result = [NSMutableData dataWithCapacity:lentext];
    
    while (true) {
        if (ixtext >= lentext) {
            break;
        }
        
        ch = temporary[ixtext++];
        flignore = false;
        
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        } else if (ch == '+') {
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
        
        if (!flignore) {
            short ctcharsinput = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinput == 0) {break;}
                
                if ((ixinput == 1) || (ixinput == 2)) {
                    ctcharsinput = 1;
                } else {
                    ctcharsinput = 2;
                }
                
                ixinput = 3;
                flbreak = true;
            }
            
            input[ixinput++] = ch;
            
            if (ixinput == 4) {
                ixinput = 0;
                
                unsigned char0 = input[0];
                unsigned char1 = input[1];
                unsigned char2 = input[2];
                unsigned char3 = input[3];
                
                output[0] = (char0 << 2) | ((char1 & 0x30) >> 4);
                output[1] = ((char1 & 0x0F) << 4) | ((char2 & 0x3C) >> 2);
                output[2] = ((char2 & 0x03) << 6) | (char3 & 0x3F);
                
                for (i = 0; i < ctcharsinput; i++) {
                    [result appendBytes: &output[i] length: 1];
                }
            }
            if (flbreak) {break;}
        }
    }
    return result;
}

#pragma mark - about string

+ (NSString *)escapeHTML:(NSString *)originalHTML
{
    NSMutableString *result = [[NSMutableString alloc] initWithString:originalHTML];
	[result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
	[result replaceOccurrencesOfString:@"'" withString:@"&#39;" options:NSLiteralSearch range:NSMakeRange(0, [result length])];
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
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *compsPast = [calendar components:unitFlags fromDate:date];
    NSDateComponents *compsNow = [calendar components:unitFlags fromDate:[NSDate date]];
    
    NSInteger years = [compsNow year] - [compsPast year];
    NSInteger months = [compsNow month] - [compsPast month] + years * 12;
    NSInteger days = [compsNow day] - [compsPast day];
    NSInteger hours = [compsNow hour] - [compsPast hour];
    NSInteger minutes = [compsNow minute] - [compsPast minute];
    
    if (months >= 12) {
        NSArray *arr = [dateStr componentsSeparatedByString:@"T"];
        return [arr objectAtIndex:0];
    } else if (months > 1) {
        return [NSString stringWithFormat:@"%i个月前", months];
    } else if (months == 1) {
        return @"一个月前";
    } else if (days > 1) {
        return [NSString stringWithFormat:@"%i天前", days];
    } else if (days == 1) {
        return @"一天前";
    } else if (hours >= 1) {
        return [NSString stringWithFormat:@"%i 小时前", hours];
    } else if (minutes >= 1) {
        return [NSString stringWithFormat:@"%i 分钟前", minutes];
    } else {
        return @"刚刚";
    }
}

+ (NSAttributedString *)getIntervalAttrStr:(NSString *)dateStr
{
    NSAttributedString *intervalAttrStr = [self grayString:[self intervalSinceNow:dateStr]
                                                  fontName:@"STHeitiSC-Medium"
                                                  fontSize:15];
    
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
    
    [portraitView sd_setImageWithURL:[NSURL URLWithString:portraitURL]
                    placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    [self roundView:portraitView cornerRadius:cornerRadius];
}

+ (UIColor *)uniformColor
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}


#pragma mark - about notifications
+ (void)toastNotification:(NSString *)text inView:(UIView *)view
{
    [view makeToast:text duration:2.0 position:@"center"];
}

+ (NSInteger)networkStatus
{
    Reachability *reach = [Reachability reachabilityWithHostName:@"git.oschina.net"];
    return [reach currentReachabilityStatus];
}

+ (BOOL)isNetworkExist
{
    return [self networkStatus] > 0;
}

+ (BOOL)isPageCacheExist:(NSInteger)type
{
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    NSArray *cachePage = [cache arrayForKey:[NSString stringWithFormat:@"type-%ld", (long)type]];
    
    return cachePage != nil;
}

+ (NSArray *)getPageCache:(NSInteger)type
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

+ (void)savePageCache:(NSArray *)page type:(NSInteger)type
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



@end
