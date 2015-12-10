//
//  FilesTableController.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilesTableController : UITableViewController

@property (nonatomic, assign) int64_t projectID;
@property (nonatomic, copy) NSString *projectName;
@property (nonatomic, copy) NSString *ownerName;
@property (nonatomic, copy) NSString *privateToken;
@property (nonatomic, copy) NSString *projectNameSpace;

@property (strong, nonatomic) NSString *currentPath;

- (id)initWithProjectID:(int64_t)projectID projectName:(NSString *)projectName ownerName:(NSString *)ownerName;

@end
