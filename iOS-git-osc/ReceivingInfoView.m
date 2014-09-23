//
//  ReceivingInfoView.m
//  Git@OSC
//
//  Created by chenhaoxiang on 14-9-21.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ReceivingInfoView.h"
#import "Tools.h"
#import "GLGitlab.h"
#import "UIView+Toast.h"

#define PLACE_HOLDER @"T恤（ S、M、L、XL ）或内裤（ L、XL、2XL、3XL ）请备注码数\n如未填写，我们将随机寄出"

@interface ReceivingInfoView ()

@property NSUserDefaults *userDefaults;

@property UITextField *nameField;
@property UITextField *phoneNumField;
@property UITextView *addressView;
@property UITextView *remarkView;
@property UIButton *buttonSave;

@end

static NSString * const kKeyTrueName = @"trueName";
static NSString * const kKeyPhoneNumber = @"phoneNumber";
static NSString * const kKeyAddress = @"address";
static NSString * const kKeyExtroInfo = @"extraInfo";

@implementation ReceivingInfoView

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"收货信息";
    self.view.backgroundColor = [Tools uniformColor];
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    [self setLayout];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![Tools isNetworkExist]) {
        _buttonSave.alpha = 0.4;
        _buttonSave.enabled = NO;
        return;
    }
    
    [self.view makeToastActivity];
    
    [[GLGitlabApi sharedInstance] fetchReceivingInfo:[[_userDefaults objectForKey:@"id"] longLongValue]
                                        privateToken:[_userDefaults objectForKey:@"private_token"]
                                             success:^(id responseObject) {
                                                 [self.view hideToastActivity];
                                                 _nameField.text = [responseObject objectForKey:@"name"];
                                                 _phoneNumField.text = [responseObject objectForKey:@"tel"];
                                                 _addressView.text = [responseObject objectForKey:@"address"];
                                                 _remarkView.text = [responseObject objectForKey:@"comment"];
                                                 if (!_nameField.text.length || !_phoneNumField.text.length || !_addressView.text.length) {
                                                     _buttonSave.alpha = 0.4;
                                                     _buttonSave.enabled = NO;
                                                 }
                                             }
                                             failure:^(NSError *error) {
                                                 [self.view hideToastActivity];
                                                 _buttonSave.alpha = 0.4;
                                                 _buttonSave.enabled = NO;
                                             }];
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
    
    _nameField = [UITextField new];
    _nameField.delegate = self;
    //_nameField.text = [_userDefaults objectForKey:kKeyTrueName];
    _nameField.enablesReturnKeyAutomatically = YES;
    _nameField.backgroundColor = [UIColor whiteColor];
    _nameField.returnKeyType = UIReturnKeyNext;
    _nameField.layer.borderWidth = 1;
    _nameField.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_nameField];
    
    _phoneNumField = [UITextField new];
    _phoneNumField.delegate = self;
    //_phoneNumField.text = [_userDefaults objectForKey:kKeyPhoneNumber];
    _phoneNumField.enablesReturnKeyAutomatically = YES;
    _phoneNumField.backgroundColor = [UIColor whiteColor];
    _phoneNumField.returnKeyType = UIReturnKeyNext;
    _phoneNumField.layer.borderWidth = 1;
    _phoneNumField.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_phoneNumField];
    
    _addressView = [UITextView new];
    _addressView.delegate = self;
    //_addressView.text = [_userDefaults objectForKey:kKeyAddress];
    _addressView.enablesReturnKeyAutomatically = YES;
    _addressView.font = [UIFont systemFontOfSize:16];
    _addressView.backgroundColor = [UIColor whiteColor];
    _addressView.returnKeyType = UIReturnKeyNext;
    _addressView.layer.borderWidth = 1;
    _addressView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_addressView];
    
    _remarkView = [UITextView new];
    _remarkView.delegate = self;
    //_remarkView.text = [_userDefaults objectForKey:kKeyExtroInfo];
    _remarkView.enablesReturnKeyAutomatically = YES;
    _remarkView.font = [UIFont systemFontOfSize:13];
    _remarkView.backgroundColor = [UIColor whiteColor];
    _remarkView.scrollEnabled = NO;
    _remarkView.text = PLACE_HOLDER;
    _remarkView.returnKeyType = UIReturnKeyDone;
    _remarkView.textColor = [UIColor lightGrayColor];
    _remarkView.layer.borderWidth = 1;
    _remarkView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_remarkView];
    
    _buttonSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [Tools roundView:_buttonSave cornerRadius:5.0];
    _buttonSave.backgroundColor = [UIColor redColor];
    [_buttonSave setTitle:@"保存" forState:UIControlStateNormal];
    _buttonSave.titleLabel.font = [UIFont systemFontOfSize:17];
    [_buttonSave addTarget:self action:@selector(saveAndSubmit) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonSave];

    
    for (UIView *subview in [self.view subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(nameLabel, phoneNumLabel, addressLabel, remarkLabel, tipsLabel,
                                                             _nameField, _phoneNumField, _addressView, _remarkView, _buttonSave);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[nameLabel]-3-[_nameField(30)]-10-[phoneNumLabel]-3-[_phoneNumField(30)]-10-[addressLabel]-3-[_addressView(50)]-10-[remarkLabel]-3-[_remarkView(65)]-10-[tipsLabel]-25-[_buttonSave(30)]"
                                                                     options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                     metrics:nil
                                                                       views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[nameLabel]-8-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
}

- (void)saveAndSubmit
{
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    } else {
        //[self.view makeToastActivity];
    }

    [_userDefaults setObject:_nameField.text forKey:kKeyTrueName];
    [_userDefaults setObject:_phoneNumField.text forKey:kKeyPhoneNumber];
    [_userDefaults setObject:_addressView.text forKey:kKeyAddress];
    [_userDefaults setObject:_remarkView.text forKey:kKeyExtroInfo];
    [_userDefaults synchronize];
    
    [[GLGitlabApi sharedInstance] updateReceivingInfo:[[_userDefaults objectForKey:@"id"] longLongValue]
                                         privateToken:[_userDefaults objectForKey:@"private_token"]
                                                 name:_nameField.text
                                          phoneNumber:_phoneNumField.text
                                              address:_addressView.text
                                            extraInfo:_remarkView.text
                                              success:^(id responseObject) {
                                                  [Tools toastNotification:@"保存成功" inView:self.view];
                                              }
                                              failure:^(NSError *error) {
                                                  [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
                                              }];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextField *anotherTextField = textField == _nameField ? _nameField : _phoneNumField;
    NSString *anotherStr = anotherTextField.text;
    
    NSMutableString *newStr = [textField.text mutableCopy];
    [newStr replaceCharactersInRange:range withString:string];
    
    if (newStr.length && anotherStr.length && _addressView.text.length) {
        _buttonSave.alpha = 1;
        _buttonSave.enabled = YES;
    } else {
        _buttonSave.alpha = 0.4;
        _buttonSave.enabled = NO;
    }
    
    if ([string isEqualToString: @"\n"]) {
        [textField resignFirstResponder];
        textField == _nameField ? [_phoneNumField becomeFirstResponder] : [_addressView becomeFirstResponder];
        return NO;
    }
    
    return YES;
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSMutableString *addressStr;
    if (textView == _addressView) {
        addressStr = [textView.text mutableCopy];
        [addressStr replaceCharactersInRange:range withString:text];
    } else {
        addressStr = [[NSMutableString alloc] initWithString:_addressView.text];
    }
    
    if (addressStr.length && _nameField.text.length && _phoneNumField.text.length) {
        _buttonSave.alpha = 1;
        _buttonSave.enabled = YES;
    } else {
        _buttonSave.alpha = 0.4;
        _buttonSave.enabled = NO;
    }
    
    if ([text isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        textView == _addressView ? [_remarkView becomeFirstResponder] : [self hideKeyboard];
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
