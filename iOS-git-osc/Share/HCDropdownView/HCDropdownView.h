//
//  HCDropdownView.h
//  DropDown
//
//  Created by Holden on 15/11/4.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*!
 Dropdown view state.
 */
typedef enum : NSUInteger {
    HCDropdownViewStateWillOpen,
    HCDropdownViewStateDidOpen,
    HCDropdownViewStateWillClose,
    HCDropdownViewStateDidClose,
} HCDropdownViewState;

@protocol HCDropdownViewDelegate;

/*!
 *  A simple dropdown view inspired by Tappy.
 */
@interface HCDropdownView : NSObject <UITableViewDataSource,UITableViewDelegate>

/*!
 *  The closed scale of container view.
 *  Set it to 1 to disable container scale animation.
 */
@property (nonatomic, assign) CGFloat closedScale;

/*!
 *  The blur radius of container view.
 */
@property (nonatomic, assign) CGFloat blurRadius;

/*!
 *  The alpha of black mask button.
 */
@property (nonatomic, assign) CGFloat blackMaskAlpha;

/*!
 *  The animation duration.
 */
@property (nonatomic, assign) CGFloat animationDuration;

/*!
 *  The animation bounce height of content view.
 */
@property (nonatomic, assign) CGFloat animationBounceHeight;

/*!
 *  The background color of content view.
 */
@property (nonatomic, strong) UIColor *contentBackgroundColor;

/*!
 *  The current dropdown view state.
 */
@property (nonatomic, assign, readonly) HCDropdownViewState currentState;

/*!
 *  A boolean indicates whether dropdown is open.
 */
@property (nonatomic, assign, readonly) BOOL isOpen;

/*!
 *  The dropdown view delegate.
 */
@property (nonatomic, weak) id<HCDropdownViewDelegate> delegate;

/**
 *  The callback when dropdown view did show in the container view.
 */
@property (nonatomic, copy) dispatch_block_t didShowHandler;

/**
 *  The callback when dropdown view did hide in the container view.
 */
@property (nonatomic, copy) dispatch_block_t didHideHandler;

/**
 *  The selection menu tabelview.
 */
@property (nonatomic, strong) UITableView *menuTabelView;

/**
 *  The selection menu tabelview row height.
 */
@property (nonatomic) CGFloat menuRowHeight;

/**
 *  The selection menu tabelview item rows.
 */
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSString *imageNameStr;
@property (nonatomic, strong) NSArray *images;



/*!
 *  Convenience constructor for LMDropdownView.
 */
+ (instancetype)dropdownView;

/*!
 *  Show dropdown view.
 *
 *  @param containerView The containerView to contain.
 *  @param contentView   The contentView to show.
 *  @param origin        The origin point in the container coordinator system.
 */

//- (void)showInView:(UIView *)containerView withContentView:(UIView *)contentView atOrigin:(CGPoint)origin;

/*!
 *  Show dropdown view from navigation controller.
 *
 *  @param navigationController The navigation controller to show from.
 *  @param origin          The contentView origin.
 */
- (void)showFromNavigationController:(UINavigationController *)navigationController menuTabelViewOrigin:(CGPoint)origin;

/*!
 *  Hide dropdown view.
 */
- (void)hide;

@end

/*!
 *  Dropdown view delegate.
 */
@protocol HCDropdownViewDelegate <NSObject>

@optional
- (void)dropdownViewWillShow:(HCDropdownView *)dropdownView;
- (void)dropdownViewDidShow:(HCDropdownView *)dropdownView;
- (void)dropdownViewWillHide:(HCDropdownView *)dropdownView;
- (void)dropdownViewDidHide:(HCDropdownView *)dropdownView;

- (void)didSelectItemAtRow:(NSInteger)row;
@end


