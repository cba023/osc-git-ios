//
//  ImageView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ImageView.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "UIView+Toast.h"
#import "UIImageView+WebCache.h"

#import <MBProgressHUD.h>

@interface ImageView ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation ImageView

- (id)initWithImageURL:(NSString *)imageURL
{
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        
        [self setLayout];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_imageURL]
                                                          options:0
                                                         progress:nil
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            [_hud hide:YES afterDelay:1];
                                                            if (image && finished) {
                                                                [_imageView setImage:image];
                                                            } else {
                                                                _hud.detailsLabelText = @"抱歉，图片加载出错";
                                                                [_hud hide:YES afterDelay:1];
                                                            }
                                                        }];
    [_hud hide:YES afterDelay:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setLayout
{
    //_scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.contentMode = UIViewContentModeScaleAspectFill;
    //_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 3;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    //_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_imageView];
    
    //CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    //CGFloat imageHeight = _imageView.image.size.height / _imageView.image.size.width * screenWidth;
    
#if 1
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_imageView, _scrollView);
    
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:viewDictionary]];
    //[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_scrollView]|" options:0 metrics:nil views:viewDictionary]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_imageView]|" options:0 metrics:nil views:viewDictionary]];
#endif
}



@end
