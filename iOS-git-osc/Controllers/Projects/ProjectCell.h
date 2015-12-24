//
//  ProjectCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-2.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLProject.h"

@interface ProjectCell : UITableViewCell

@property UIImageView *portrait;
@property UILabel *projectNameField;
@property UILabel *projectDescriptionField;
@property UILabel *lSFWLabel;
//@property UILabel *starsCount;
//@property UILabel *forksCount;
//@property UILabel *updatetimeField;

- (void)contentForProjects:(GLProject *)project;

@end
