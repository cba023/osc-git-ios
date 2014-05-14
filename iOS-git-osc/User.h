//
//  User.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-13.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+ (void)loginWithAccount:(NSString *)account andPassword:(NSString *)password;

@end
