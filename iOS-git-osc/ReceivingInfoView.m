//
//  ReceivingInfoView.m
//  Git@OSC
//
//  Created by chenhaoxiang on 14-9-21.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ReceivingInfoView.h"
#import "Tools.h"

#define PLACE_HOLDER @"T恤（ S、M、L、XL ）或内裤（ L、XL、2XL、3XL ）请备注码数\n如未填写，我们将随机寄出"

@interface ReceivingInfoView ()

@property UITextField *nameField;
@property UITextField *phoneNumField;
@property UITextView *addressView;
@property UITextView *remarkView;
@property UIButton *buttonSave;

@end

@implementation ReceivingInfoView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"收货信息";
    self.view.backgroundColor = [Tools uniformColor];
    
    [self setLayout];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setLayout
{
    UILabel *nameLabel = [UILabel new];
    nameLabel.backgroundColor = [Tools uniformColor];
    nameLabel.font = [UIFont boldSystemFontOfSize:17];
    nameLabel.text = @"真实姓名 *";
    [self.view addSubview:nameLabel];
    
    UILabel *phoneNumLabel = [UILabel new];
    phoneNumLabel.backgroundColor = [Tools uniformColor];
    phoneNumLabel.font = [UIFont boldSystemFontOfSize:17];
    phoneNumLabel.text = @"手机号码 *";
    [self.view addSubview:phoneNumLabel];
    
    UILabel *addressLabel = [UILabel new];
    addressLabel.backgroundColor = [Tools uniformColor];
    addressLabel.font = [UIFont boldSystemFontOfSize:17];
    addressLabel.text = @"收货地址 *";
    [self.view addSubview:addressLabel];
    
    UILabel *remarkLabel = [UILabel new];
    remarkLabel.backgroundColor = [Tools uniformColor];
    remarkLabel.font = [UIFont boldSystemFontOfSize:17];
    remarkLabel.text = @"备注";
    [self.view addSubview:remarkLabel];
    
    UILabel *tipsLabel = [UILabel new];
    tipsLabel.numberOfLines = 2;
    tipsLabel.text = @"tips:\n\t如有疑问，欢迎 @昊翔 或 @阿娇OSC";
    tipsLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:tipsLabel];
    
    _buttonSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [Tools roundView:_buttonSave cornerRadius:5.0];
    _buttonSave.backgroundColor = [UIColor redColor];
    [_buttonSave setTitle:@"保存" forState:UIControlStateNormal];
    _buttonSave.titleLabel.font = [UIFont systemFontOfSize:17];
    _buttonSave.alpha = 0.4;
    _buttonSave.enabled = NO;
    [_buttonSave addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonSave];
    
    _nameField = [UITextField new];
    _nameField.backgroundColor = [UIColor whiteColor];
    _nameField.returnKeyType = UIReturnKeyNext;
    _nameField.layer.borderWidth = 1;
    _nameField.layer.borderColor = [[UIColor grayColor] CGColor];
    [_nameField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_nameField];
    
    _phoneNumField = [UITextField new];
    _phoneNumField.backgroundColor = [UIColor whiteColor];
    _phoneNumField.returnKeyType = UIReturnKeyNext;
    _phoneNumField.layer.borderWidth = 1;
    _phoneNumField.layer.borderColor = [[UIColor grayColor] CGColor];
    [_phoneNumField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.view addSubview:_phoneNumField];
    
    _addressView = [UITextView new];
    _addressView.delegate = self;
    _addressView.backgroundColor = [UIColor whiteColor];
    _addressView.returnKeyType = UIReturnKeyNext;
    _addressView.layer.borderWidth = 1;
    _addressView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_addressView];
    
    _remarkView = [UITextView new];
    _remarkView.delegate = self;
    _remarkView.backgroundColor = [UIColor whiteColor];
    _remarkView.scrollEnabled = NO;
    _remarkView.text = PLACE_HOLDER;
    _remarkView.textColor = [UIColor lightGrayColor];
    _remarkView.layer.borderWidth = 1;
    _remarkView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_remarkView];

    
    for (UIView *subview in [self.view subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(nameLabel, phoneNumLabel, addressLabel, remarkLabel, tipsLabel,
                                                             _nameField, _phoneNumField, _addressView, _remarkView, _buttonSave);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[nameLabel]-3-[_nameField(30)]-10-[phoneNumLabel]-3-[_phoneNumField(30)]-10-[addressLabel]-3-[_addressView(50)]-10-[remarkLabel]-3-[_remarkView(60)]-10-[tipsLabel]-25-[_buttonSave(30)]"
                                                                     options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                     metrics:nil
                                                                       views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[nameLabel]-8-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
}

- (void)save
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:_nameField.text forKey:@"trueName"];
    [userDefaults setObject:_phoneNumField.text forKey:@"phoneNumber"];
    [userDefaults setObject:_addressView.text forKey:@"address"];
    [userDefaults setObject:_remarkView.text forKey:@"extraInfo"];
}

- (void)hideKeyboard
{
    [_nameField resignFirstResponder];
    [_phoneNumField resignFirstResponder];
    [_addressView resignFirstResponder];
    [_remarkView resignFirstResponder];
    
    [self resumeView];
}

- (void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat y;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        y = 64;
    } else {
        y = 0;
    }
    
    CGRect rect=CGRectMake(0.0f, y, width, height);
    self.view.frame=rect;
    
    [UIView commitAnimations];
}

- (void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == _nameField) {
        [_phoneNumField becomeFirstResponder];
    } else {
        [_addressView becomeFirstResponder];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        [self save];
        return NO;
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat y = textView == _addressView? -60 : -100;
    CGRect rect = CGRectMake(0.0f, y, width, height);
    self.view.frame = rect;
    
    [UIView commitAnimations];
    
    // 清除placeholder
    
    if (textView == _remarkView && [textView.text isEqualToString:PLACE_HOLDER]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    // 恢复placeholder
    
    if (textView == _remarkView && [textView.text isEqualToString:@""]) {
        textView.text = PLACE_HOLDER;
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}


@end
