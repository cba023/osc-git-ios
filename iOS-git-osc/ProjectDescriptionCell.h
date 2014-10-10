//
//  ProjectDescriptionCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectDescriptionCell : UITableViewCell

@property UILabel *projectDescriptionField;
@property UIButton *starButton;
@property UIButton *watchButton;
@property UILabel *starsCountLabel;
@property UILabel *watchesCountLabel;

@property BOOL isStarred;
@property BOOL isWatched;
@property NSInteger starsCount;
@property NSInteger watchesCount;

- (id)initWithStarsCount:(NSInteger)starsCount
            watchesCount:(NSInteger)watchesCount
               isStarred:(BOOL)isStarred
               isWatched:(BOOL)isWatched
             description:(NSString *)projectDescription;


@end
