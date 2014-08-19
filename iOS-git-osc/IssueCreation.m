//
//  IssueCreation.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-18.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "IssueCreation.h"
#import "Issue.h"
#import "Project.h"
#import "Tools.h"
#import "GLGitlab.h"
#import "Issue.h"

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
    
    //[self getMembersAndMilestones];
    [self initSubviews];
    [self setAutoLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getMembersAndMilestones
{
    _members = [Project getTeamMembersForProjectId:_projectId];
    _milestones = [Issue getMilestonesForProjectId:_projectId page:1];
}

- (void)initSubviews
{
#if 0
    _consignorLabel = [UILabel new];
    _consignorLabel.text = @"指派人";
    [self.view addSubview:_consignorLabel];
    
    _mileStoneLabel = [UILabel new];
    _mileStoneLabel.text = @"里程碑";
    [self.view addSubview:_mileStoneLabel];
    
    _consignor = [UIPickerView new];
    [self.view addSubview:_consignor];
    
    _milestone = [UIPickerView new];
    [self.view addSubview:_milestone];
#endif
    
    _titleLabel = [UILabel new];
    _titleLabel.text = @"标题";
    [self.view addSubview:_titleLabel];
    
    _issueTitle = [UITextField new];
    _issueTitle.layer.borderWidth = 0.8;
    _issueTitle.layer.cornerRadius = 3.0;
    _issueTitle.returnKeyType = UIReturnKeyNext;
    _issueTitle.layer.borderColor = [[UIColor grayColor] CGColor];
    _issueTitle.delegate = self;
    [self.view addSubview:_issueTitle];
    
    _descriptionLabel = [UILabel new];
    _descriptionLabel.text = @"描述";
    [self.view addSubview:_descriptionLabel];
    
    _description = [UITextView new];
    _description.layer.borderWidth = 0.8;
    _description.layer.cornerRadius = 3.0;
    _description.layer.borderColor = [[UIColor grayColor] CGColor];
    _description.returnKeyType = UIReturnKeyDone;
    _description.autocorrectionType = UITextAutocorrectionTypeNo;
    _description.enablesReturnKeyAutomatically = YES;
    _description.delegate = self;
    [self.view addSubview:_description];
    
    [_issueTitle addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    _submit = [UIButton new];
    [Tools roundCorner:_submit cornerRadius:5.0];
    _submit.tintColor = [UIColor whiteColor];
    _submit.backgroundColor = [UIColor redColor];
    [Tools roundCorner:_submit cornerRadius:5.0];
    [_submit setTitle:@"创建Issue" forState:UIControlStateNormal];
    [_submit addTarget:self action:@selector(submitIssue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submit];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
#if 0
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_titleLabel]-[_issueTitle(15)]-8-[_consignorLabel]-[_consignor(30)]-8-[_mileStoneLabel]-[_milestone(30)]-8-[_descriptionLabel]-[_description(40)]-20-[_submit(40)]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_titleLabel, _issueTitle,
                                                                                                             _consignorLabel, _consignor,
                                                                                                             _mileStoneLabel, _milestone,
                                                                                                             _descriptionLabel, _description,
                                                                                                             _submit)]];
#endif
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_titleLabel]-[_issueTitle(40)]-20-[_descriptionLabel]-[_description(150)]-30-[_submit]"
                                                                     options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_titleLabel, _issueTitle,
                                                                                                            _descriptionLabel, _description,
                                                                                                            _submit)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-10-[_submit]-10-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_submit)]];
}

- (void)submitIssue
{
    GLIssue *issue = [GLIssue new];
    issue.projectId = _projectId;
    issue.title = _issueTitle.text;
    issue.issueDescription = _description.text;
    [Issue createIssue:issue];
}

#if 0
#pragma mark - UIPickerView things

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _consignor) {
        return [_members count];
    } else {
        return [_milestones count];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == _consignor) {
        GLUser *user = [_members objectAtIndex:row];
        return user.name;
    } else {
        GLMilestone *milestone = [_milestones objectAtIndex:row];
        return milestone.title;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}
#endif

#pragma mark - 键盘操作

#if 0
- (void)shouldBeginEditing
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移30个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,-30,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self shouldBeginEditing];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self shouldBeginEditing];
    return YES;
}

- (void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //如果当前View是父视图，则Y为20个像素高度，如果当前View为其他View的子视图，则动态调节Y的高度
    float Y = 20.0f;
    CGRect rect=CGRectMake(0.0f,Y,width,height);
    self.view.frame=rect;
    [UIView commitAnimations];
}
#endif

- (void)hidenKeyboard
{
    [self.issueTitle resignFirstResponder];
    [self.description resignFirstResponder];
    //[self resumeView];
}

//点击键盘上的Return按钮响应的方法
- (void)returnOnKeyboard:(UITextField *)sender
{
    [self.description becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString: @"\n"]) {
        [self hidenKeyboard];
        return NO;
    }
    return YES;
}



@end
