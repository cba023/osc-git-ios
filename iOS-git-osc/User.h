//
//  User.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-13.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLUser;

@interface User : NSObject

+ (void)saveAccount:(NSString *)email andPassword:(NSString *)password;
+ (void)saveUserInformation:(GLUser *)user;

@end
