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

@interface ImageView ()

@property UIScrollView *scrollView;
@property NSString *imageURL;

@end

@implementation ImageView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.view makeToastActivity];
    
    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:_imageURL]
                                                          options:0
                                                         progress:nil
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            if (image && finished) {
                                                                [self.view hideToastActivity];
                                                                [_imageView setImage:image];
                                                            } else {
                                                                [Tools toastNotification:@"抱歉，图片加载出错" inView:self.view];
                                                            }
                                                        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setLayout
{
    _scrollView = [UIScrollView new];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.contentMode = UIViewContentModeScaleAspectFill;
    //_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 3;
    _scrollView.bounces = NO;
    [self.view addSubview:_scrollView];
    
    _imageView = [UIImageView new];
    //_imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    //_imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_scrollView addSubview:_imageView];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_imageView, _scrollView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_scrollView]|" options:0 metrics:nil views:viewDictionary]];

    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_imageView]|" options:0 metrics:nil views:viewDictionary]];
    [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_imageView]|" options:0 metrics:nil views:viewDictionary]];
}



@end
