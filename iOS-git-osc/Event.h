//
//  Event.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

+ (NSArray *)getEventsWithPrivateToekn:(NSString *)private_token page:(int)page;
+ (NSString *)getEventDescriptionWithAuthor:(NSString *)author
                                     action:(int)action
                               projectOwner:(NSString *)projectOwner
                                projectName:(NSString *)projectName
                               otherMessage:(NSString *)otherMessage;

@end
