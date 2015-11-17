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

+ (NSAttributedString *)getEventDescriptionForEvent:(GLEvent *)event;
+ (NSAttributedString *)generateEventAbstract:(GLEvent *)event;
+ (void)setAbstractContent:(UITextView *)textView forEvent:(GLEvent *)event;

@end
