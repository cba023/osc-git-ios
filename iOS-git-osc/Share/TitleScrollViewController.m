//
//  TitleScrollViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/11/24.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "TitleScrollViewController.h"
#import "HMSegmentedControl.h"
#import "ProjectsTableController.h"
#import "EventsView.h"
#import "AccountManagement.h"
#import "SetUpsViewController.h"

#import "UIColor+Util.h"
#import "UIImageView+WebCache.h"

@interface TitleScrollViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, copy) NSString *portrait;

@property (nonatomic, strong) HMSegmentedControl *titleSegment;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat  sizeWidth;
@property (nonatomic, assign) CGFloat  sizeHeight;
@property (nonatomic, assign) CGFloat  heightForTopView;
@property (nonatomic, assign) CGFloat  heightForTitle;

@property ProjectsTableController *recommendedProjects;
@property ProjectsTableController *hotProjects;
@property ProjectsTableController *recentUpdatedProjects;

@property EventsView *eventsView;
@property ProjectsTableController *ownProjects;
@property ProjectsTableController *starredProjects;
@property ProjectsTableController *watchedProjects;

@end

@implementation TitleScrollViewController

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)titles andSubControllers:(NSArray *)controllers andUnderTabbar:(BOOL)underTabbar andUserPortrait:(BOOL)userPortrait
{
    self = [super init];
    if (self) {
        self.title = title;
        
        _sizeWidth = self.view.frame.size.width;
        _sizeHeight = self.view.frame.size.height-64;
        _heightForTitle = 35; //滚动标题高度
        
        if (userPortrait) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            img.layer.cornerRadius = 15;
            img.clipsToBounds = YES;
            
            _portrait = [[NSUserDefaults standardUserDefaults] objectForKey:@"new_portrait"];
            if (_portrait) {
                [img sd_setImageWithURL:[NSURL URLWithString:_portrait]];
            } else {
                img.image = [UIImage imageNamed:@"userNotLoggedIn"];
            }
            img.userInteractionEnabled = YES;
            [img addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myInfos)]];
            
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:img];
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SetUp"]
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(setUp)];
        }
        if (underTabbar) {
            _heightForTopView = 49; //底部工具栏高度
        } else {
            _heightForTopView = 0;
        }
        
        //标题滚动
        [self initSubviewForTitleSegment:titles];
        //列表
        [self initSubViewForControllers:controllers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - 标题滚动
- (void)initSubviewForTitleSegment:(NSArray *)titles
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _titleSegment = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, _sizeWidth, _heightForTitle)];//
    [_titleSegment setSectionTitles:titles];
    [_titleSegment setSelectedSegmentIndex:0];
    
    [_titleSegment setBackgroundColor:[UIColor whiteColor]];
    [_titleSegment setTextColor:[UIColor blackColor]];
    [_titleSegment setSelectedTextColor:[UIColor navigationbarColor]];
    [_titleSegment setSelectionIndicatorColor:[UIColor navigationbarColor]];
    
    [_titleSegment setSelectionStyle:HMSegmentedControlSelectionStyleBox];
    [_titleSegment setSelectionIndicatorLocation:HMSegmentedControlSelectionIndicatorLocationDown];
    [self.view addSubview:_titleSegment];
    
    __weak typeof(self) weakSelf = self;//点击滚动标题的动作
    [_titleSegment setIndexChangeBlock:^(NSInteger index) {
        
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(weakSelf.sizeWidth * index, weakSelf.heightForTitle, weakSelf.sizeWidth, weakSelf.sizeHeight-_heightForTitle-_heightForTopView) animated:YES];
    }];
}

#pragma mark - 列表数组
- (void)initSubViewForControllers:(NSArray *)controllers
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _heightForTitle, self.sizeWidth, self.sizeHeight-_heightForTitle-_heightForTopView)];//
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setBounces:NO];
    [_scrollView setContentSize:CGSizeMake(_sizeWidth*controllers.count, _sizeHeight-_heightForTitle-_heightForTopView)];
    [_scrollView scrollRectToVisible:CGRectMake(0, _heightForTitle, _sizeWidth, _sizeHeight-_heightForTitle-_heightForTopView) animated:YES];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    int i = 0;
    for (UIViewController *controller in controllers) {
        controller.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-_heightForTitle-_heightForTopView);
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView addSubview:controller.view];
        [self addChildViewController:controller];
        i++;
    }
}

#pragma mark - 设置

- (void)myInfos
{
    AccountManagement *accountManagement = [AccountManagement new];
    accountManagement.hidesBottomBarWhenPushed = YES;
    [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:accountManagement animated:YES];
}

- (void)setUp
{
    SetUpsViewController *setUpController = [SetUpsViewController new];
    setUpController.hidesBottomBarWhenPushed = YES;
    [(UINavigationController *)self.tabBarController.selectedViewController pushViewController:setUpController animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    NSInteger page = scrollView.contentOffset.x / pageWidth;
    
    [_titleSegment setSelectedSegmentIndex:page animated:YES];
}

@end
