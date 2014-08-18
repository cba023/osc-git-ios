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
#import "UIViewController+REFrostedViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize loginTableView;

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
    
    self.title = @"登录";

    self.accountTextField = [[UITextField alloc] initWithFrame: CGRectMake(78, 98, 212, 30)];
    self.accountTextField.placeholder = @"Email";
    self.accountTextField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    self.accountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.accountTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountTextField.delegate = self;
    self.accountTextField.returnKeyType = UIReturnKeyNext;
    
    self.passwordTextField = [[UITextField alloc] initWithFrame: CGRectMake(78, 151, 212, 30)];
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.delegate = self;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    
    [self.accountTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    UILabel* accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 102, 42, 21)];
    accountLabel.text = @"账号";
    UILabel* passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 155, 42, 21)];
    passwordLabel.text = @"密码";
    
    UIButton* summit = [UIButton buttonWithType:UIButtonTypeCustom];
    [Tools roundCorner:summit cornerRadius:5.0];
    summit.frame = CGRectMake(137, 200, 46, 30);
    summit.backgroundColor = [UIColor redColor];
    [summit setTitle:@"登录" forState:UIControlStateNormal];
    [summit addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: accountLabel];
    [self.view addSubview: passwordLabel];
    [self.view addSubview: self.accountTextField];
    [self.view addSubview: self.passwordTextField];
    [self.view addSubview: summit];

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

- (void)login {
    [User loginWithAccount:self.accountTextField.text andPassword:self.passwordTextField.text];
    EventsView *eventsView = [EventsView new];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [userDefaults objectForKey:@"private_token"];
    eventsView.privateToken = privateToken;
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:eventsView];
    self.frostedViewController.contentViewController = navigationController;
}


#pragma mark - 键盘操作

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
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
    return YES;
}

-(void)resumeView
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

-(void)hidenKeyboard
{
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self resumeView];
}

//点击键盘上的Return按钮响应的方法
-(void)returnOnKeyboard:(UITextField *)sender
{
    if (sender == self.accountTextField) {
        [self.passwordTextField becomeFirstResponder];
    }else if (sender == self.passwordTextField){
        [self hidenKeyboard];
    }
}


@end
