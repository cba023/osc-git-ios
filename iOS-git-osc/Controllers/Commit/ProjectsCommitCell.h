//
//  ProjectsMemberCell.h
//  Git@OSC
//
//  Created by 李萍 on 15/11/27.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLCommit.h"

@interface ProjectsCommitCell : UITableViewCell

@property (nonatomic, strong) UIImageView *memberImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UILabel *createtimeLabel;

- (void)contentForProjectsCommit:(GLCommit *)commit;

@end
