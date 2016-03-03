//
//  FeedBackViewController.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/15.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "FeedBackViewController.h"
#import "UIColor+Util.h"
#import "Tools.h"
#import "AFHTTPRequestOperationManager+Util.h"
#import "GITAPI.h"
#import "PlaceholderTextView.h"

#import "GLIssue.h"
#import "GLIssueFeedImage.h"

#import <ReactiveCocoa.h>
#import <MBProgressHUD.h>

@interface FeedBackViewController () <UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIButton *programErrorView;
@property (nonatomic, strong) UIButton *recommentFunctionView;
@property (nonatomic, strong) PlaceholderTextView *textView;
@property (nonatomic, strong) UIImageView *printscrenImagView;
@property (nonatomic, strong) UIButton *feedButton;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *feedBackType;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"意见反馈";
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor uniformColor];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    [self initSubView];
    _feedBackType = @"程序错误";

    /*** binding ***/
    
    RACSignal *valid = [RACSignal combineLatest:@[_textView.rac_textSignal]
                                         reduce:^(NSString *feedBackString) {
                                             return @(feedBackString.length > 0);
                                         }];
    RAC(_feedButton, enabled) = valid;
    RAC(_feedButton, alpha) = [valid map:^(NSNumber *b) {
        return b.boolValue ? @1: @0.4;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubView
{
    _programErrorView = [UIButton new];
    [_programErrorView setImage:[UIImage imageNamed:@"feedback_selected"] forState:UIControlStateNormal];
    [_programErrorView addTarget:self action:@selector(selectedType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_programErrorView];
    _programErrorView.tag = 1;
    
    UILabel *programErrorLabel = [UILabel new];
    programErrorLabel.text = @"程序错误";
    programErrorLabel.font = [UIFont systemFontOfSize:15];
    programErrorLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:programErrorLabel];
    
    _recommentFunctionView = [UIButton new];
    [_recommentFunctionView setImage:[UIImage imageNamed:@"feedback_unSelected"] forState:UIControlStateNormal];
    [_recommentFunctionView addTarget:self action:@selector(selectedType:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_recommentFunctionView];
    _recommentFunctionView.tag = 2;
    
    UILabel *recommentFunctionLabel = [UILabel new];
    recommentFunctionLabel.text = @"功能建议";
    recommentFunctionLabel.font = [UIFont systemFontOfSize:15];
    recommentFunctionLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:recommentFunctionLabel];
    
    _textView = [PlaceholderTextView new];
    _textView.placeholder = @"请提出您的意见与建议,我们会仔细阅读并尽早给您回复。感谢您的理解和支持";
    _textView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_textView];
    
    UILabel *label = [UILabel new];
    label.text = @"截图描述：（可选）";
    label.textColor = [UIColor darkGrayColor];
    label.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:label];
    
    _printscrenImagView = [UIImageView new];
    _printscrenImagView.backgroundColor = [UIColor whiteColor];
    [Tools roundView:_printscrenImagView cornerRadius:5];
    _printscrenImagView.image = [UIImage imageNamed:@"image_add_sel"];
    [self.view addSubview:_printscrenImagView];
    self.printscrenImagView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(takeprintscreen)];
    [self.printscrenImagView addGestureRecognizer:tap1];
    
    _feedButton = [UIButton new];
    [_feedButton setTitle:@"发表意见" forState:UIControlStateNormal];
    [Tools roundView:_feedButton cornerRadius:5.0];
    [_feedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _feedButton.backgroundColor = [UIColor redColor];
    [self.view addSubview:_feedButton];
    [_feedButton addTarget:self action:@selector(feedBack) forControlEvents:UIControlEventTouchUpInside];
    
    
    for (UIView *view in self.view.subviews) {view.translatesAutoresizingMaskIntoConstraints = NO;}
    NSDictionary *views = NSDictionaryOfVariableBindings(_programErrorView, programErrorLabel, _recommentFunctionView, recommentFunctionLabel, _textView, label, _printscrenImagView, _feedButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_programErrorView(20)]-15-[_textView(150)]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_recommentFunctionView(20)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[_programErrorView(20)]-5-[programErrorLabel(100)]-30-[_recommentFunctionView(20)]-5-[recommentFunctionLabel]"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_textView(150)]-20-[label]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[_textView]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label]-10-[_printscrenImagView(50)]-30-[_feedButton(35)]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[_printscrenImagView(50)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[_feedButton]-15-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
}

#pragma mark - 键盘收回
- (void)hidenKeyboard
{
    [_textView resignFirstResponder];
    
}

#pragma mark - 选择反馈类型
- (void)selectedType:(UIButton *)sender
{
    if (sender.tag == 1) {
        [_programErrorView setImage:[UIImage imageNamed:@"feedback_selected"] forState:UIControlStateNormal];
        [_recommentFunctionView setImage:[UIImage imageNamed:@"feedback_unSelected"] forState:UIControlStateNormal];
        _feedBackType = @"程序错误";
    } else if (sender.tag == 2) {
        [_programErrorView setImage:[UIImage imageNamed:@"feedback_unSelected"] forState:UIControlStateNormal];
        [_recommentFunctionView setImage:[UIImage imageNamed:@"feedback_selected"] forState:UIControlStateNormal];
        _feedBackType = @"功能建议";
    }
}

#pragma mark - 选择截图
- (void)takeprintscreen
{
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.allowsEditing = NO;
    imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _image = info[UIImagePickerControllerOriginalImage];
    
    [picker dismissViewControllerAnimated:YES completion:^ {
        _printscrenImagView.image = _image;
    }];
}

#pragma mark - 当前时间
- (NSString *)locationTime
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];
    
    return timeString;
}

# pragma mark - 发表意见

- (void)feedBack
{
    if (_image) {
        [self feedBackWithImages];
    } else {
        [self feedBackWithText:@""];
    }
}

- (void)feedBackWithText:(NSString *)imageUrl
{

    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = MBProgressHUDModeCustomView;
    
    
    GLIssue *issue = [GLIssue new];
    issue.projectId = 211189;
    issue.title = [NSString stringWithFormat:@"[iPhone客户端-%@-%@]", _feedBackType, [self locationTime]];
    if (imageUrl.length) {
        issue.issueDescription = [NSString stringWithFormat:@"%@![](%@)", _textView.text, imageUrl];
    } else {
        issue.issueDescription = _textView.text;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@/142144/issues", GITAPI_HTTPS_PREFIX, GITAPI_PROJECTS];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[issue jsonCreateRepresentation]];
    [params setObject:[Tools getPrivateToken] forKey:@"private_token"];
    [params setObject:@(355540) forKey:@"assignee_id"];
    
    [manager POST:strUrl
       parameters:params
          success:^(AFHTTPRequestOperation * operation, id responseObject) {
              if (responseObject == nil) {
                  _hud.detailsLabelText = @"网络错误";
              } else {
                  _hud.detailsLabelText = @"反馈成功";
                  
                  [self.navigationController popViewControllerAnimated:YES];
              }
              [_hud hide:YES afterDelay:1];
          } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              if (error != nil) {
                  _hud.detailsLabelText = [NSString stringWithFormat:@"网络异常，错误码：%ld", (long)error.code];
              } else {
                  _hud.detailsLabelText = @"网络错误";
              }
              [_hud hide:YES afterDelay:1];
          }];
}

- (void)feedBackWithImages
{

    _hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    _hud.userInteractionEnabled = NO;
    _hud.mode = MBProgressHUDModeCustomView;
     
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager GitManager];
    
    [manager POST:@"https://git.oschina.net/upload"
       parameters:@{@"private_token" : [Tools getPrivateToken]}
constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [_hud hide:YES afterDelay:1];
    
        if (_image) {
            [formData appendPartWithFileData:[Tools compressImage:_image]
                                        name:@"files"
                                    fileName:@"feedback_img.jpg"
                                    mimeType:@"image/jpeg"];
        }
    } success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        GLIssueFeedImage *filesImage = [[GLIssueFeedImage alloc] initWithJSON:responseObject];
        if (filesImage.isSuccess) {
            [_hud hide:YES afterDelay:1];
            NSString *imageUrl = [filesImage.files objectForKey:@"url"];
            [self feedBackWithText:imageUrl];
        } else {
            _hud.detailsLabelText = @"网络错误";
            [_hud hide:YES afterDelay:1];
        }
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        _hud.detailsLabelText = @"网络错误";
        [_hud hide:YES afterDelay:1];
    }];
    
}

@end
