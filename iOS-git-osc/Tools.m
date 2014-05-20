//
//  Tools.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Tools.h"
#import <CommonCrypto/CommonDigest.h>
#import <SDWebImage/UIImageView+WebCache.h>

@implementation Tools

+ (NSString *) md5: (NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  [NSString stringWithString: output];
}

+ (UIImage *) loadImage:(NSString *)urlString {
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

@end
