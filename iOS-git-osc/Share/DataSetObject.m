//
//  DataSetObject.m
//  zbapp
//
//  Created by Holden on 15/10/15.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "DataSetObject.h"

@implementation DataSetObject

- (instancetype)initWithSuperScrollView:(UIScrollView*)sv
{
    self = [super init];
    if (self) {
        sv.emptyDataSetDelegate = self;
        sv.emptyDataSetSource = self;
    }
    return self;
}


#pragma mark - DZNEmptyDataSetSource
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    if ( _state == noDataState || _state == failureLoadState) {
        return _emptyDefaultImage?_emptyDefaultImage:[UIImage imageNamed:@"page_icon_empty"];
    } else if ( _state == netWorkingErrorState) {
        return [UIImage imageNamed:@"page_icon_network"];
    } else if (_state == emptyViewState){
        return [UIImage new];
    }
    return nil;
}

- (UIView *)customViewForEmptyDataSet:(UIScrollView *)scrollView
{
    if (_state == loadingState) {
        UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen]bounds]), CGRectGetHeight([[UIScreen mainScreen]bounds]))];
        subView.backgroundColor = [UIColor clearColor];
        subView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView startAnimating];
        [subView addSubview:activityView];
        
        UILabel *label = [UILabel new];
        label.text = @"加载中...";
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        [subView addSubview:label];
        
        if (_isNotShowPrompting) {
            [activityView stopAnimating];
            label.hidden = YES;
        }
        for (UIView *view in subView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
        NSDictionary *views = NSDictionaryOfVariableBindings(activityView, label);
        
        [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[activityView]-30-[label]"
                                                                        options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                        metrics:nil views:views]];
        
        [subView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-100-[activityView]-100-|"
                                                                        options:0
                                                                        metrics:nil views:views]];
        
        return subView;
    } else if (_state == emptyViewState) {
        return [UIView new];
    }
    return nil;
}


- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text;
    if (_state == loadingState) {
        text = @"加载中...";
    } else if (_state == noDataState) {
        text = _respondString?_respondString:@"没有相关数据";
    } else if (_state == failureLoadState) {
        text = _respondString?_respondString:@"加载失败";
    } else if (_state == netWorkingErrorState) {
        text = @"网络未连接";
    } else if (_state == emptyViewState) {
        text = @"";
    }
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                 NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName : paragraph
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state
{
    if (_state == failureLoadState || _state == netWorkingErrorState) {
        NSDictionary *attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:14],
                                     NSForegroundColorAttributeName : [UIColor lightGrayColor]
                                     };
        
        return [[NSAttributedString alloc] initWithString:@"点击重新加载" attributes:attributes];
    }
    return nil;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0;//-44
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 20;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return NO;
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView
{
    if (self.reloading) {
        self.reloading();
    }
}

- (void)emptyDataSetDidTapView:(UIScrollView *)scrollView
{
    if (self.reloading) {
        self.reloading();
    }
}

@end
