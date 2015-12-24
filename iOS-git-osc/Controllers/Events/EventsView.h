//
//  EventsView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventsView : UITableViewController <UIScrollViewDelegate>

- (id)initWithPrivateToken:(NSString *)privateToken;
- (id)initWithUserID:(int64_t)userID;

@end
