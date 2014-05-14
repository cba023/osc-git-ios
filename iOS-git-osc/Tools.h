//
//  Tools.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (NSString *) md5: (NSString *) input;
+ (UIImage *) loadImage: (NSURL *) imageURL;

@end
