//
//  UserDetailsView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailsView : UIViewController

- (id)initWithPrivateToken:(NSString *)privateToken userID:(int64_t)userID;

@end
