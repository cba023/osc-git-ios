//
//  LoginViewController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "LoginViewController.h"
#import "NavigationController.h"
#import "User.h"
#import "Tools.h"
#import "EventsView.h"
#import "Event.h"
#import "GLGitlab.h"
#import "UIViewController+REFrostedViewController.h"

@interface LoginViewController ()

@property UIButton *submit;

@end

@implementation LoginViewController

@synthesize loginTableView;
@synthesize submit;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"登录";
    
    [self initSubviews];
    [self setLayout];
    
    
#if 1
    [self.navigationController.navigationBar setTranslucent:NO];
#else
    //适配iOS7uinavigationbar遮挡tableView的问题
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
    {
        self.parentViewController.edgesForExtendedLayout = UIRectEdgeNone;
        self.parentViewController.automaticallyAdjustsScrollViewInsets = NO;
    }
#endif
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(NavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - about subviews
- (void)initSubviews
{
    self.accountTextField = [UITextField new];
    self.accountTextField.placeholder = @"Email";
    self.accountTextField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    self.accountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.accountTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountTextField.delegate = self;
    self.accountTextField.returnKeyType = UIReturnKeyNext;
    self.accountTextField.enablesReturnKeyAutomatically = YES;
    
    self.passwordTextField = [UITextField new];
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.enablesReturnKeyAutomatically = YES;
    
    [self.accountTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    [self.view addSubview: self.accountTextField];
    [self.view addSubview: self.passwordTextField];
}

- (void)setLayout
{
    UIImageView *loginLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginLogo"]];
    loginLogo.contentMode = UIViewContentModeScaleAspectFit;
    UIImageView *email = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email"]];
    email.contentMode = UIViewContentModeScaleAspectFill;
    UIImageView *password = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"password"]];
    password.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:loginLogo];
    [self.view addSubview:email];
    [self.view addSubview:password];
    
    submit = [UIButton buttonWithType:UIButtonTypeCustom];
    [Tools roundView:submit cornerRadius:5.0];
    submit.backgroundColor = [UIColor redColor];
    [submit setTitle:@"登录" forState:UIControlStateNormal];
    submit.titleLabel.font = [UIFont systemFontOfSize:17];
    submit.alpha = 0.4;
    submit.enabled = NO;
    [submit addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: submit];
    
    UILabel *tips = [UILabel new];
    tips.font = [UIFont systemFontOfSize:12];
    tips.textColor = [UIColor grayColor];
    tips.lineBreakMode = NSLineBreakByCharWrapping;
    tips.numberOfLines = 0;
    tips.text = @"tips:\n\t请使用Git@OSC的push邮箱和密码登录\n\t注册请前往 https://git.oschina.net";
    [self.view addSubview:tips];
    
    for (UIView *view in [self.view subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[loginLogo(90)]-25-[email(20)]-20-[password(20)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(loginLogo, email, password)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=50-[loginLogo(90)]->=50-|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(loginLogo)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginLogo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[email(20)]-[_accountTextField]-30-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(email, _accountTextField)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[password(20)]-[_passwordTextField]-30-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(password, _passwordTextField)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[password]->=20-[submit(30)]-20-[tips]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(password, submit, tips)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_passwordTextField]-30-[submit]"
                                                                      options:NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_passwordTextField, submit)]];
}


#pragma mark - 键盘操作

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
#if 0
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //上移30个单位，按实际情况设置
    CGRect rect=CGRectMake(0.0f,-30,width,height);
    self.view.frame=rect;
#endif
    CGRect frame = self.view.frame;
    frame.origin.y -= 40;
    frame.size.height += 40;
    self.view.frame = frame;
    [UIView commitAnimations];
    return YES;
}

- (void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect frame = self.view.frame;
    frame.origin.y += 40;
    frame.size. height -= 40;
    self.view.frame = frame;
#if 0
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    //如果当前View是父视图，则Y为20个像素高度，如果当前View为其他View的子视图，则动态调节Y的高度
    float Y = 20.0f;
    CGRect rect=CGRectMake(0.0f,Y,width,height);
    self.view.frame=rect;
#endif
    [UIView commitAnimations];
}

- (void)hidenKeyboard
{
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self resumeView];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    UITextField *anotherTextField = textField == self.accountTextField ? self.passwordTextField : self.accountTextField;
    NSString *anotherStr = anotherTextField.text;
    
    NSMutableString *newStr = [textField.text mutableCopy];
    [newStr replaceCharactersInRange:range withString:string];
    
    if (newStr.length && anotherStr.length) {
        submit.alpha = 1;
        submit.enabled = YES;
    } else {
        submit.alpha = 0.4;
        submit.enabled = NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    submit.enabled = NO;
    return YES;
}

//点击键盘上的Return按钮响应的方法
- (void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == self.accountTextField) {
        [self.passwordTextField becomeFirstResponder];
    }else if (sender == self.passwordTextField){
        [self login];
    }
}

- (void)login {
    GLGitlabSuccessBlock success = ^(id responseObject) {
        GLUser *user = responseObject;
        if (responseObject == nil){
            [Tools toastNotification:@"网络错误" inView:self.view];
        } else {
            [User saveUserInformation:user];
            
            EventsView *eventsView = [[EventsView alloc] initWithPrivateToken:user.private_token];
            NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:eventsView];
            self.frostedViewController.contentViewController = navigationController;
        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            [Tools toastNotification:[error description] inView:self.view];
        }
    };
    
    [[GLGitlabApi sharedInstance] loginWithEmail:_accountTextField.text
                                        Password:_passwordTextField.text
                                         Success:success
                                         Failure:failure];
}



@end
