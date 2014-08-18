//
//  IssueCreation.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-18.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssueCreation.h"
#import "Tools.h"

@interface IssueCreation ()

@end

@implementation IssueCreation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"创建Issue";
    
    [self initSubviews];
    [self setAutoLayout];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSubviews
{
    _titleLabel = [UILabel new];
    _titleLabel.text = @"标题";
    [self.view addSubview:_titleLabel];
    
    _consignorLabel = [UILabel new];
    _consignorLabel.text = @"指派人";
    [self.view addSubview:_consignorLabel];
    
    _mileStoneLabel = [UILabel new];
    _mileStoneLabel.text = @"里程碑";
    [self.view addSubview:_mileStoneLabel];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.text = @"描述";
    [self.view addSubview:_descriptionLabel];
    
    _issueTitle = [UITextField new];
    _issueTitle.borderStyle = UITextBorderStyleLine;
    [self.view addSubview:_issueTitle];
    
    _consignor = [UIPickerView new];
    [self.view addSubview:_consignor];
    
    _mileStone = [UIPickerView new];
    [self.view addSubview:_mileStone];
    
    _description = [UITextView new];
    _description.layer.borderColor = [[UIColor blackColor] CGColor];
    [self.view addSubview:_description];
    
    _submit = [UIButton new];
    [Tools roundCorner:_submit cornerRadius:5.0];
    _submit.tintColor = [UIColor whiteColor];
    _submit.backgroundColor = [UIColor redColor];
    [Tools roundCorner:_submit cornerRadius:5.0];
    [_submit setTitle:@"创建Issue" forState:UIControlStateNormal];
    //[_submit addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_submit];
    
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_titleLabel]-[_issueTitle(15)]-8-[_consignorLabel]-[_consignor(30)]-8-[_mileStoneLabel]-[_mileStone(30)]-8-[_descriptionLabel]-[_description(40)]-20-[_submit(40)]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_titleLabel, _issueTitle,
                                                                                                             _consignorLabel, _consignor,
                                                                                                             _mileStoneLabel, _mileStone,
                                                                                                             _descriptionLabel, _description,
                                                                                                             _submit)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_submit]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_submit)]];
}


@end
