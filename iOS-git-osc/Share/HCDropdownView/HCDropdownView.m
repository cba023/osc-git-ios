//
//  HCDropdownView.m
//  DropDown
//
//  Created by Holden on 15/11/4.
//  Copyright © 2015年 oschina. All rights reserved.
//

#import "HCDropdownView.h"
#import "HCDropdownMenuCell.h"
#import "UIImage+LMExtension.h"

#define kDefaultClosedScale                 0.85
#define kDefaultBlurRadius                  5
#define kDefaultBlackMaskAlpha              0.5
#define kDefaultAnimationDuration           0.5
#define kDefaultAnimationBounceHeight       20
#define kDefaultAnimationBounceScale        0.05

@interface HCDropdownView ()
{
    CGPoint originContentCenter;
    CGPoint desContentCenter;
}
@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIView *contentWrapperView;
@property (nonatomic, strong) UIImageView *containerWrapperView;
@property (nonatomic, strong) UIButton *backgroundButton;

@property (nonatomic, strong) UINavigationController *currentNav;
@property (nonatomic) CGPoint origin;
@end

@implementation HCDropdownView

#pragma mark - INIT
+ (instancetype)dropdownView
{
    return [[HCDropdownView alloc] init];
}

- (id)init
{
    self = [super init];
    if (self) {
        _closedScale = kDefaultClosedScale;
        _blurRadius = kDefaultBlurRadius;
        _blackMaskAlpha = kDefaultBlackMaskAlpha;
        _animationDuration = kDefaultAnimationDuration;
        _animationBounceHeight = kDefaultAnimationBounceHeight;
        _currentState = HCDropdownViewStateDidClose;
        self.contentBackgroundColor = [UIColor whiteColor];
        
        _menuTabelView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.menuTabelView.backgroundColor = self.contentBackgroundColor;
        _menuTabelView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
        [_menuTabelView registerNib:[UINib nibWithNibName:@"HCDropdownMenuCell" bundle:nil] forCellReuseIdentifier:@"HCCell"];
        _menuTabelView.dataSource = self;
        _menuTabelView.delegate = self;
        
    }
    return self;
}
#pragma mark - PUBLIC METHOD

- (BOOL)isOpen
{
    return (_currentState == HCDropdownViewStateDidOpen);
}
- (void)showFromNavigationController:(UINavigationController *)navigationController menuTabelViewOrigin:(CGPoint)origin
{
    _currentNav = navigationController;
    _origin = origin;
    
    if ([navigationController.visibleViewController isKindOfClass:[UITableViewController class]]) {
        UITableView *tableView = (UITableView*)navigationController.visibleViewController.view;
        tableView.scrollEnabled = NO;
    }
    [self showInView:navigationController.visibleViewController.view];
}
- (void)showInView:(UIView *)containerView {
    if (_currentState != HCDropdownViewStateDidClose) {
        return;
    }
    
    // Start showing
    _currentState = HCDropdownViewStateWillOpen;
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropdownViewWillShow:)]) {
        [self.delegate dropdownViewWillShow:self];
    }

    
    // Setup menu in view
    [self setupMenuTabelViewInView:containerView];
    
    // Animate menu view controller
    [self addContentAnimationForState:_currentState];
    
    // Animate content view controller
    if (self.closedScale < 1) {
        [self addContainerAnimationForState:_currentState];
    }
    
    // Finish showing
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _currentState = HCDropdownViewStateDidOpen;
        if (self.delegate && [self.delegate respondsToSelector:@selector(dropdownViewDidShow:)]) {
            [self.delegate dropdownViewDidShow:self];
        }
        if (self.didShowHandler) {
            self.didShowHandler();
        }
    });
}

#pragma mark - PRIVATE

- (void)setupMenuTabelViewInView:(UIView *)containerView
{
    /*!
     *  Prepare container captured image
     */
    CGSize containerSize = [containerView bounds].size;
    CGFloat scale = (3 - 2 * self.closedScale);
    CGSize capturedSize = CGSizeMake(containerSize.width * scale, containerSize.height * scale);
    UIImage *capturedImage = [UIImage imageFromView:containerView withSize:capturedSize];
    UIImage *blurredCapturedImage = [capturedImage blurredImageWithRadius:self.blurRadius iterations:5 tintColor:[UIColor clearColor]];
    
    /*!
     *  Main View
     */
    if (!self.mainView) {
        self.mainView = [[UIScrollView alloc] init];
    }
    self.mainView.frame = containerView.bounds;

    [containerView addSubview:self.mainView];
    /*!
     *  Container Wrapper View
     */
    if (!self.containerWrapperView) {
        self.containerWrapperView = [[UIImageView alloc] init];
        self.containerWrapperView.backgroundColor = [UIColor whiteColor];
        self.containerWrapperView.contentMode = UIViewContentModeCenter;
    }
    self.containerWrapperView.image = blurredCapturedImage;
    self.containerWrapperView.bounds = CGRectMake(0,
                                                  0,
                                                  capturedSize.width,
                                                  capturedSize.height);
    self.containerWrapperView.center = self.mainView.center;
    [self.mainView addSubview:self.containerWrapperView];
    
    /*!
     *  Background Button
     */
    if (!self.backgroundButton) {
        self.backgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backgroundButton addTarget:self action:@selector(backgroundButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIColor *maskColor = [[UIColor blackColor] colorWithAlphaComponent:self.blackMaskAlpha];
    self.backgroundButton.backgroundColor = maskColor;
    self.backgroundButton.frame = self.mainView.bounds;
    [self.mainView addSubview:self.backgroundButton];
    
    /*!
     *  Content Wrapper View
     */
    if (!self.contentWrapperView) {
        self.contentWrapperView = [[UIView alloc] init];
    }
    self.contentWrapperView.backgroundColor = self.contentBackgroundColor;

    _menuTabelView.frame = CGRectMake(0,
                                      self.animationBounceHeight,
                                   CGRectGetWidth(_menuTabelView.frame),
                                   CGRectGetHeight(_menuTabelView.frame));
    
    [self.contentWrapperView addSubview:_menuTabelView];

    
    CGFloat contentWrapperViewHeight = CGRectGetHeight(_menuTabelView.frame) + self.animationBounceHeight;

    self.contentWrapperView.frame = CGRectMake(_origin.x,
                                               _origin.y - contentWrapperViewHeight,
                                               CGRectGetWidth(_menuTabelView.frame),
                                               contentWrapperViewHeight);
    
    [self.mainView addSubview:self.contentWrapperView];
    
    originContentCenter = CGPointMake(CGRectGetMidX(self.contentWrapperView.frame), CGRectGetMidY(self.contentWrapperView.frame));
    desContentCenter = CGPointMake(CGRectGetMidX(self.contentWrapperView.frame), CGRectGetMinY(_menuTabelView.frame) + contentWrapperViewHeight/2 - 2*self.animationBounceHeight);
}


- (void)backgroundButtonTapped:(id)sender
{
    [self hide];
}

- (void)setClosedScale:(CGFloat)closedScale
{
    _closedScale = MIN(closedScale, 1);
}

- (void)hide
{
    if (_currentState != HCDropdownViewStateDidOpen) {
        return;
    }

    // Start hiding
    _currentState = HCDropdownViewStateWillClose;

    if (self.delegate && [self.delegate respondsToSelector:@selector(dropdownViewWillHide:)]) {
        [self.delegate dropdownViewWillHide:self];
    }
    
    // Animate menu view controller
    [self addContentAnimationForState:_currentState];
    
    // Animate content view controller
    if (self.closedScale < 1) {
        [self addContainerAnimationForState:_currentState];
    }
    
    // Finish hiding
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        _currentState = HCDropdownViewStateDidClose;

        if (self.delegate && [self.delegate respondsToSelector:@selector(dropdownViewDidHide:)]) {
            [self.delegate dropdownViewDidHide:self];
        }
        if (self.didHideHandler) {
            self.didHideHandler();
        }
        
        [UIView animateWithDuration:0.2 animations:^{
//            self.mainView.alpha = 0;
        } completion:^(BOOL finished) {
//            self.mainView.alpha = 1;
            [self.contentWrapperView removeFromSuperview];
            [self.backgroundButton removeFromSuperview];
            [self.containerWrapperView removeFromSuperview];
            [self.mainView removeFromSuperview];
        }];
    });
}
#pragma mark - KEYFRAME ANIMATION

- (void)addContentAnimationForState:(HCDropdownViewState)state
{
    CAKeyframeAnimation *contentBounceAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    contentBounceAnim.duration = self.animationDuration;
    contentBounceAnim.delegate = self;
    contentBounceAnim.removedOnCompletion = NO;
    contentBounceAnim.fillMode = kCAFillModeForwards;
    contentBounceAnim.values = [self contentPositionValuesForState:state];
    contentBounceAnim.timingFunctions = [self contentTimingFunctionsForState:state];
    contentBounceAnim.keyTimes = [self contentKeyTimesForState:state];
    
    [self.contentWrapperView.layer addAnimation:contentBounceAnim forKey:nil];
    [self.contentWrapperView.layer setValue:[contentBounceAnim.values lastObject] forKeyPath:@"position"];
}

- (void)addContainerAnimationForState:(HCDropdownViewState)state
{
    CAKeyframeAnimation *containerScaleAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    containerScaleAnim.duration = self.animationDuration;
    containerScaleAnim.delegate = self;
    containerScaleAnim.removedOnCompletion = NO;
    containerScaleAnim.fillMode = kCAFillModeForwards;
    containerScaleAnim.values = [self containerTransformValuesForState:state];
    containerScaleAnim.timingFunctions = [self containerTimingFunctionsForState:state];
    containerScaleAnim.keyTimes = [self containerKeyTimesForState:state];
    
    [self.containerWrapperView.layer addAnimation:containerScaleAnim forKey:nil];
    [self.containerWrapperView.layer setValue:[containerScaleAnim.values lastObject] forKeyPath:@"transform"];
}


#pragma mark - PROPERTIES FOR KEYFRAME ANIMATION

- (NSArray *)contentPositionValuesForState:(HCDropdownViewState)state
{
    CGFloat positionX = self.contentWrapperView.layer.position.x;
    CGFloat positionY = self.contentWrapperView.layer.position.y;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    [values addObject:[NSValue valueWithCGPoint:self.contentWrapperView.layer.position]];
    
    if (state == HCDropdownViewStateWillOpen || state == HCDropdownViewStateDidOpen)
    {
        [values addObject:[NSValue valueWithCGPoint:CGPointMake(positionX, desContentCenter.y + self.animationBounceHeight)]];
        [values addObject:[NSValue valueWithCGPoint:CGPointMake(positionX, desContentCenter.y)]];
    }
    else
    {
        [values addObject:[NSValue valueWithCGPoint:CGPointMake(positionX, positionY + self.animationBounceHeight)]];
        [values addObject:[NSValue valueWithCGPoint:CGPointMake(positionX, originContentCenter.y)]];
    }
    
    return values;
}

- (NSArray *)contentKeyTimesForState:(HCDropdownViewState)state
{
    NSMutableArray *keyTimes = [[NSMutableArray alloc] init];
    [keyTimes addObject:[NSNumber numberWithFloat:0]];
    [keyTimes addObject:[NSNumber numberWithFloat:0.5]];
    [keyTimes addObject:[NSNumber numberWithFloat:1]];
    return keyTimes;
}

- (NSArray *)contentTimingFunctionsForState:(HCDropdownViewState)state
{
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] init];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return timingFunctions;
}

- (NSArray *)containerTransformValuesForState:(HCDropdownViewState)state
{
    CATransform3D transform = self.containerWrapperView.layer.transform;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    [values addObject:[NSValue valueWithCATransform3D:transform]];
    
    if (state == HCDropdownViewStateWillOpen || state == HCDropdownViewStateDidOpen)
    {
        CGFloat scale = self.closedScale - kDefaultAnimationBounceScale;
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DScale(transform, scale, scale, scale)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DScale(transform, self.closedScale, self.closedScale, self.closedScale)]];
    }
    else
    {
        CGFloat scale = 1 - kDefaultAnimationBounceScale;
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DScale(transform, scale, scale, scale)]];
        [values addObject:[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    }
    
    return values;
}

- (NSArray *)containerKeyTimesForState:(HCDropdownViewState)state
{
    NSMutableArray *keyTimes = [[NSMutableArray alloc] init];
    [keyTimes addObject:[NSNumber numberWithFloat:0]];
    [keyTimes addObject:[NSNumber numberWithFloat:0.5]];
    [keyTimes addObject:[NSNumber numberWithFloat:1]];
    return keyTimes;
}

- (NSArray *)containerTimingFunctionsForState:(HCDropdownViewState)state
{
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] init];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    return timingFunctions;
}

#pragma mark -- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titles.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    HCDropdownMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HCCell" forIndexPath:indexPath];
    cell.backgroundColor = _contentBackgroundColor;
    cell.titleLabel.text = [_titles objectAtIndex:indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:_imageNameStr];
    cell.iconImageView.image = [UIImage imageNamed:_images[indexPath.row]];
    return cell;
}
#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self hide];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtRow:)]) {
        [self.delegate didSelectItemAtRow:indexPath.row];
    }
}
@end
