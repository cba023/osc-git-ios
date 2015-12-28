//
//  DataSetObject.h
//  zbapp
//
//  Created by Holden on 15/10/15.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIScrollView+EmptyDataSet.h>

typedef NS_ENUM(NSInteger, netWorkingState)
{
    loadingState,
    failureLoadState,
    noDataState,
    netWorkingErrorState,
    emptyViewState
};

@interface DataSetObject : NSObject<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, assign) netWorkingState state;
@property (nonatomic, copy) void (^reloading)();
@property (nonatomic, copy) NSString *respondString;     //自定义的加载结果提示语
@property (nonatomic, assign) BOOL isNotShowPrompting;          //是否显示加载中的等待提醒
@property (nonatomic, strong) UIImage *emptyDefaultImage;    //自定义无数据时的默认图片

-(instancetype)initWithSuperScrollView:(UIScrollView*)sv;

@end
