//
//  ProjectNameCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-6.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLProject;

@interface ProjectNameCell : UITableViewCell

@property GLProject *project;

@property UIImageView *portrait;
@property UILabel *projectName;
@property UILabel *timeInterval;

- (id)initWithProject:(GLProject *)project;

@end
