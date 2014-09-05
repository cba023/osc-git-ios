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
                                                             NSLog(@"%ld, %ld", (long)receivedSize, (long)expectedSize);
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
    NSString *timeString=@"";
    NSTimeInterval interval = [date timeIntervalSinceNow] * (-1);
    
    if (interval/3600 < 1) {
        if (interval/60<1) {
            timeString = @"1";
        } else {
            timeString = [NSString stringWithFormat:@"%f", interval/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString=[NSString stringWithFormat:@"%@ 分钟前", timeString];
    } else if (interval/3600 > 1 && interval/86400 < 1) {
        timeString = [NSString stringWithFormat:@"%f", interval/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@ 小时前", timeString];
    } else if (interval/86400 > 1 && interval/864000 < 1) {
        timeString = [NSString stringWithFormat:@"%f", interval/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString = [NSString stringWithFormat:@"%@ 天前", timeString];
    } else {
        NSArray *arr = [dateStr componentsSeparatedByString:@"T"];
        timeString = [arr objectAtIndex:0];
    }
    return timeString;
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
    
    Class class = type < 8? [GLProject class]: [GLEvent class];
    
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
    
    [cache synchronize];
}

+ (NSUInteger)numberOfRepeatedProjects:(NSArray *)projects project:(GLProject *)project
{
    NSUInteger len = [projects count];
    GLProject *projectInArray;
    for (NSUInteger i = 1; i <= len; i++) {
        projectInArray = [projects objectAtIndex:len-i];
        if (projectInArray.projectId == project.projectId) {
            return i;
        }
    }
    
    return 0;
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



@end
