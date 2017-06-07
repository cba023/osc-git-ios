//
//  OSCShareManager.h
//  iosapp
//
//  Created by wupei on 2017/6/7.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GLProject.h"

@class OSCShareManager;

@protocol OSCShareManagerDelegate <NSObject>

@optional
- (void)shareManagerCustomShareModeWithManager:(OSCShareManager* )shareManager
                         shareBoardIndexButton:(NSInteger)buttonTag;

@end

@interface OSCShareManager : NSObject

+ (instancetype)shareManager;


- (void)hiddenShareBoard;

/** 项目分享 */
- (void)showShareBoardWithProjectM:(GLProject *)projectM
                            URLStr:(NSString *)urlStr
                             image:(UIImage *)snipImg;

@property (nonatomic, weak) id <OSCShareManagerDelegate> delegate;

@end

#pragma mark --- OSCShareBoard

@class OSCShareBoard;
@protocol OSCShareBoardDelegate <NSObject>

@optional
- (BOOL)customShareModeWithShareBoard:(OSCShareBoard* )shareBoard
                     boardIndexButton:(NSInteger)buttonTag;

@end

@interface OSCShareBoard : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (instancetype)shareBoardWithProjectModel:(GLProject *)projectM urlStr:(NSString *)urlStr image:(UIImage *)snipImg;

@property (nonatomic, weak) id <OSCShareBoardDelegate> delegate;

@end
