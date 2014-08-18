//
//  Event.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLEvent;

@interface Event : NSObject

+ (NSArray *)getEventsWithPrivateToekn:(NSString *)private_token page:(int)page;
+ (NSAttributedString *)getEventDescriptionForEvent:(GLEvent *)event;
+ (NSArray *)getUserEvents:(int64_t)userId page:(int)page;

@end
