//
//  ReceivingInfoView.m
//  Git@OSC
//
//  Created by chenhaoxiang on 14-9-21.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "ReceivingInfoView.h"
#import "Tools.h"

@interface ReceivingInfoView ()

@property UITextField *nameField;
@property UITextField *phoneNumField;
@property UITextField *addressField;
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
    [self.view addSubview:_nameField];
    
    _phoneNumField = [UITextField new];
    _phoneNumField.backgroundColor = [UIColor whiteColor];
    _phoneNumField.returnKeyType = UIReturnKeyNext;
    _phoneNumField.layer.borderWidth = 1;
    _phoneNumField.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_phoneNumField];
    
    _addressField = [UITextField new];
    _addressField.backgroundColor = [UIColor whiteColor];
    _addressField.returnKeyType = UIReturnKeyNext;
    _addressField.layer.borderWidth = 1;
    _addressField.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_addressField];
    
    _remarkView = [UITextView new];
    _remarkView.backgroundColor = [UIColor whiteColor];
    _remarkView.scrollEnabled = NO;
    _remarkView.text = @"T恤（ S、M、L、XL ）或内裤（ L、XL、2XL、3XL ）请备注码数\n如未填写，我们将随机寄出";
    _remarkView.textColor = [UIColor lightGrayColor];
    _remarkView.layer.borderWidth = 1;
    _remarkView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:_remarkView];

    
    for (UIView *subview in [self.view subviews]) {
        subview.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(nameLabel, phoneNumLabel, addressLabel, remarkLabel, tipsLabel,
                                                             _nameField, _phoneNumField, _addressField, _remarkView, _buttonSave);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[nameLabel]-5-[_nameField(30)]-12-[phoneNumLabel]-5-[_phoneNumField(30)]-12-[addressLabel]-5-[_addressField(30)]-12-[remarkLabel]-5-[_remarkView(60)]-12-[tipsLabel]-25-[_buttonSave(30)]"
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
    
}


@end
