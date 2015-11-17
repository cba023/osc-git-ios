//
//  ImageView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageView : UIViewController <UIScrollViewDelegate>

@property UIImageView *imageView;

- (id)initWithImageURL:(NSString *)imageURL;

@end
