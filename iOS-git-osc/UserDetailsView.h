//
//  UserDetailsView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLUser;

@interface UserDetailsView : UIViewController

@property GLUser *user;
@property NSArray *events;

@property UIImageView *portrait;
@property UILabel *name;

@property UILabel *followersCount;
@property UILabel *followingsCount;
@property UILabel *projects;
@property UILabel *starredCount;
@property UILabel *watchedCount;

@property UITableView *eventsTable;

@end
