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

@property (nonatomic, strong)UIImageView *portrait;
@property (nonatomic, strong)UILabel *projectNameField;
@property (nonatomic, strong)UILabel *projectDescriptionField;
@property (nonatomic, strong)UILabel *lSFWLabel;
//@property UILabel *starsCount;
//@property UILabel *forksCount;
//@property UILabel *updatetimeField;

- (void)contentForProjects:(GLProject *)project;

@end
