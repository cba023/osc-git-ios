//
//  NoteCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLComment.h"

@interface NoteCell : UITableViewCell

@property UIImageView *portrait;
@property UILabel *author;
@property UILabel *body;
@property UILabel *time;

- (void)contentForProjectsComment:(GLComment *)comment;

@end
