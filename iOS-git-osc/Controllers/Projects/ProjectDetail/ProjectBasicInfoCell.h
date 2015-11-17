//
//  ProjectBasicInfoCell.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectBasicInfoCell : UITableViewCell <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property UICollectionView *basicInfo;

@property NSArray *info;

- (id)initWithCreatedTime:(NSString *)createdTime
               forksCount:(NSInteger)forksCount
                 isPublic:(BOOL)isPublic
                 language:(NSString *)language;

@end
