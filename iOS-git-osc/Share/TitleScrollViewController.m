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

@property (nonatomic, strong) HMSegmentedControl *titleSegment;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat  sizeWidth;
@property (nonatomic, assign) CGFloat  sizeHeight;
@property (nonatomic, assign) CGFloat  heightForTopView;

@property ProjectsTableController *recommendedProjects;
@property ProjectsTableController *hotProjects;
@property ProjectsTableController *recentUpdatedProjects;

@property EventsView *eventsView;
@property ProjectsTableController *ownProjects;
@property ProjectsTableController *starredProjects;
@property ProjectsTableController *watchedProjects;

@end

@implementation TitleScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _titleName;
    
    _sizeWidth = self.view.frame.size.width;
    _sizeHeight = self.view.frame.size.height-64;

    if (_isTabbarItem) {
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        img.layer.cornerRadius = 15;
        img.clipsToBounds = YES;
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
    
    [self fetchForTopView];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _titleSegment = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0+_heightForTopView, _sizeWidth, 30)];//
    [_titleSegment setSectionTitles:_subTitles];
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

        [weakSelf.scrollView scrollRectToVisible:CGRectMake(weakSelf.sizeWidth * index, 30+_heightForTopView, weakSelf.sizeWidth, weakSelf.sizeHeight-30) animated:YES];
    }];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30+_heightForTopView, self.sizeWidth, self.sizeHeight-30)];//
    [_scrollView setPagingEnabled:YES];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setBounces:NO];
    [_scrollView setContentSize:CGSizeMake(_sizeWidth*_subTitles.count, _sizeHeight-30-_heightForTopView)];
    [_scrollView scrollRectToVisible:CGRectMake(0, 30+_heightForTopView, _sizeWidth, _sizeHeight-30-_heightForTopView) animated:YES];
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    if (_isProject) {
        for (int i = 0; i < 3; i ++) {
            switch (i) {
                case 0:
                {
                    _recommendedProjects = [[ProjectsTableController alloc] initWithProjectsType:ProjectsTypeFeatured];
                    _recommendedProjects.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-30);
                    _recommendedProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [_scrollView addSubview:_recommendedProjects.view];
                    [self addChildViewController:_recommendedProjects];
                    break;
                }
                case 1:
                {
                    _hotProjects = [[ProjectsTableController alloc] initWithProjectsType:ProjectsTypePopular];
                    _hotProjects.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-30);
                    _hotProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [_scrollView addSubview:_hotProjects.view];
                    [self addChildViewController:_hotProjects];
                    break;
                }
                case 2:
                {
                    _recentUpdatedProjects = [[ProjectsTableController alloc] initWithProjectsType:ProjectsTypeLatest];
                    _recentUpdatedProjects.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-30);
                    _recentUpdatedProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [_scrollView addSubview:_recentUpdatedProjects.view];
                    [self addChildViewController:_recentUpdatedProjects];
                    break;
                }
                default:
                    break;
            }
        }

    } else {
        for (int i = 0; i < 4; i ++) {
            switch (i) {
                case 0:
                {
                    if (_privateToken) {
                        _eventsView = [[EventsView alloc] initWithPrivateToken:_privateToken];
                    } else {
                        _eventsView = [[EventsView alloc] initWithUserID:_userID];
                    }
                    _eventsView.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-30);
                    _eventsView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [_scrollView addSubview:_eventsView.view];
                    [self addChildViewController:_eventsView];
                    break;
                }
                case 1:
                {
                    if (_privateToken) {
                        _ownProjects = [[ProjectsTableController alloc] initWithPrivateToken:_privateToken];
                    } else {
                        _ownProjects = [[ProjectsTableController alloc] initWithUserID:_userID andProjectsType:ProjectsTypeUserProjects];
                    }
                    _ownProjects.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-30);
                    _ownProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [_scrollView addSubview:_ownProjects.view];
                    [self addChildViewController:_ownProjects];
                    break;
                }
                case 2:
                {
                    _starredProjects = [[ProjectsTableController alloc] initWithUserID:_userID andProjectsType:ProjectsTypeStared];
                    _starredProjects.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-30);
                    _starredProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [_scrollView addSubview:_starredProjects.view];
                    [self addChildViewController:_starredProjects];
                    break;
                }
                case 3:
                {
                    _watchedProjects = [[ProjectsTableController alloc] initWithUserID:_userID andProjectsType:ProjectsTypeWatched];
                    _watchedProjects.view.frame = CGRectMake(_sizeWidth*i, 0, _sizeWidth, _sizeHeight-30);
                    _watchedProjects.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [_scrollView addSubview:_watchedProjects.view];
                    [self addChildViewController:_watchedProjects];
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)layoutForTopView
{
    for (UIView *view in self.topView.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_imageView, _nameLabel);
    
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_imageView(50)]-7-[_nameLabel]"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:views]];
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_imageView(50)]" options:0 metrics:nil views:views]];
    
    [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_nameLabel]-10-|" options:0 metrics:nil views:views]];
}

- (void)fetchForTopView
{
    if (_portrait) {
        [_imageView sd_setImageWithURL:[NSURL URLWithString:_portrait]];
    } else {
        _imageView.image = [UIImage imageNamed:@"userNotLoggedIn"];
    }

    _nameLabel.text = _name;

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
