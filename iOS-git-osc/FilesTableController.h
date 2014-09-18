//
//  FilesTableController.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilesTableController : UITableViewController

@property int64_t projectID;
@property NSString *projectName;
@property NSString *ownerName;
@property NSString *privateToken;

@property NSMutableArray *filesArray;
@property (strong, nonatomic) NSString *currentPath;

- (id)initWithProjectID:(int64_t)projectID projectName:(NSString *)projectName ownerName:(NSString *)ownerName;

@end
