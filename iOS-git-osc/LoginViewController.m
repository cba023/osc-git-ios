//
//  LoginViewController.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-5-9.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "Tools.h"
#import "EventsView.h"
#import "Event.h"
#import "GLGitlab.h"
#import "UserDetailsView.h"
#import "PKRevealController.h"
#import "UIView+Toast.h"
#import "TTTAttributedLabel.h"
#import "SSKeychain.h"

@interface LoginViewController () <UIGestureRecognizerDelegate, UIActionSheetDelegate, TTTAttributedLabelDelegate>

@property UIButton *submit;
@property TTTAttributedLabel *tips;

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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
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
    
    if (self.navigationController.viewControllers.count <= 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                                 style:UIBarButtonItemStylePlain
                                                                                target:self
                                                                                action:@selector(showMenu)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [userDefaults objectForKey:@"email"];

    NSString *password = [SSKeychain passwordForService:@"Git@OSC" account:email];
    
    _accountTextField.text = email ?: @"";
    _passwordTextField.text = password ?: @"";
    
    if (!_accountTextField.text.length || !_passwordTextField.text.length) {
        submit.alpha = 0.4;
        submit.enabled = NO;
    }
}

- (void)showMenu
{
    [self.navigationController.revealController showViewController:self.navigationController.revealController.leftViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    [self.view addSubview: self.accountTextField];
    [self.view addSubview: self.passwordTextField];
    
    submit = [UIButton buttonWithType:UIButtonTypeCustom];
    [Tools roundView:submit cornerRadius:5.0];
    submit.backgroundColor = [UIColor redColor];
    [submit setTitle:@"登录" forState:UIControlStateNormal];
    submit.titleLabel.font = [UIFont systemFontOfSize:17];
    [submit addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: submit];
    
    _tips = [TTTAttributedLabel new];
    _tips.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    _tips.delegate = self;
    _tips.font = [UIFont systemFontOfSize:12];
    _tips.textColor = [UIColor grayColor];
    _tips.lineBreakMode = NSLineBreakByWordWrapping;
    _tips.numberOfLines = 0;
    _tips.text = @"tips:\n\t请使用Git@OSC的push邮箱和密码登录\n\t注册请前往 https://git.oschina.net";
    [self.view addSubview:_tips];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    gesture.delegate = self;
    [self.view addGestureRecognizer:gesture];
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
    
    for (UIView *view in [self.view subviews]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(loginLogo, email, password, _accountTextField, _passwordTextField, _tips, submit);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[loginLogo(90)]-25-[email(20)]-20-[password(20)]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|->=50-[loginLogo(90)]->=50-|"
                                                                      options:NSLayoutFormatAlignAllCenterX
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:loginLogo
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f constant:0.f]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[email(20)]-[_accountTextField]-30-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[password(20)]-[_passwordTextField]-30-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[password]->=20-[submit(35)]-20-[_tips]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:viewsDict]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_passwordTextField]-30-[submit]"
                                                                      options:NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:viewsDict]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (![_accountTextField isFirstResponder] && ![_passwordTextField isFirstResponder]) {
        return NO;
    }
    return YES;
}


#pragma mark - 键盘操作

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    
    CGFloat y = -50;
    CGRect rect = CGRectMake(0.0f, y, width, height);
    self.view.frame = rect;
    
    [UIView commitAnimations];
    
    return YES;
}

- (void)resumeView
{
    NSTimeInterval animationDuration=0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:animationDuration];
#if 1
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;
    //如果当前View是父视图，则Y为20个像素高度，如果当前View为其他View的子视图，则动态调节Y的高度
    CGFloat y;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        y = 64;
    } else {
        y = 0;
    }

    CGRect rect=CGRectMake(0.0f, y, width, height);
    self.view.frame=rect;
#else
    CGRect frame = self.view.frame;
    frame.origin.y += 40;
    frame.size. height -= 40;
    self.view.frame = frame;
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
    }else if (sender == self.passwordTextField) {
        [self hidenKeyboard];
        [self login];
    }
}

- (void)login {
    if (![Tools isNetworkExist]) {
        [Tools toastNotification:@"网络连接失败，请检查网络设置" inView:self.view];
        return;
    } else {
        [self.view makeToastActivity];
    }
    
    GLGitlabSuccessBlock success = ^(id responseObject) {
        [self.view hideToastActivity];
        GLUser *user = responseObject;
        if (responseObject == nil){
            [Tools toastNotification:@"网络错误" inView:self.view];
        } else {
            [User saveUserInformation:user];
            [User saveAccount:user.email andPassword:_passwordTextField.text];
            
            UserDetailsView *ownDetailsView = [[UserDetailsView alloc] initWithPrivateToken:user.private_token userID:user.userId];
            UINavigationController *front = [[UINavigationController alloc] initWithRootViewController:ownDetailsView];
            [self.revealController setFrontViewController:front];
            [self.revealController showViewController:self.revealController.frontViewController];
        }
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        [self.view hideToastActivity];
        if (error != nil) {
            [Tools toastNotification:@"账号密码错误" inView:self.view];
        }
    };
    
    [[GLGitlabApi sharedInstance] loginWithEmail:_accountTextField.text
                                        Password:_passwordTextField.text
                                         Success:success
                                         Failure:failure];
}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"打开链接", nil), nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}




@end
