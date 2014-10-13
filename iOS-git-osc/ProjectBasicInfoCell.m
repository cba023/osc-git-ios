//
//  ProjectBasicInfoCell.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-4.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ProjectBasicInfoCell.h"
#import "Tools.h"

@implementation ProjectBasicInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (id)initWithCreatedTime:(NSString *)createdTime forksCount:(NSInteger)forksCount isPublic:(BOOL)isPublic language:(NSString *)language
{
    self = [super init];
    if (self) {
        _info = @[
                  @[[Tools intervalSinceNow:createdTime], [NSString stringWithFormat:@"%ld", (long)forksCount]],
                  @[isPublic ? @"Public" : @"Private", language ?: @"Unknown"]
                  ];
        
        [self setLayout];
    }
    
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLayout
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumInteritemSpacing = 2;
    flowLayout.minimumLineSpacing = 2;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _basicInfo = [[UICollectionView alloc] initWithFrame:self.contentView.frame collectionViewLayout:flowLayout];
    _basicInfo.delegate = self;
    _basicInfo.dataSource = self;
    _basicInfo.backgroundColor = [UIColor clearColor];
    
    [_basicInfo registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"BasicInfoCell"];
    [self.contentView addSubview:_basicInfo];
    
    _basicInfo.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_basicInfo]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_basicInfo)]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_basicInfo]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:NSDictionaryOfVariableBindings(_basicInfo)]];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BasicInfoCell" forIndexPath:indexPath];
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(39, 10, 130, 21)];
    infoLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:infoLabel];
    UIImageView *infoImage = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 15, 15)];
    infoImage.contentMode = UIViewContentModeScaleAspectFit;
    NSArray *imageNames = @[
                            @[@"projectDetails_time", @"projectDetails_fork"],
                            @[@"projectDetails_public", @"projectDetails_language"]
                            ];
    NSString *imageName = [[imageNames objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    infoImage.image = [UIImage imageNamed:imageName];
    [cell addSubview:infoImage];
    
    infoLabel.text = [[_info objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    infoLabel.textColor = [UIColor grayColor];
    
    return cell;
}



- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = _basicInfo.frame.size;
    return CGSizeMake(size.width/2 - 6, size.height/2 - 6);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}



@end
