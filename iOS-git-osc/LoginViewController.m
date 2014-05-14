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

#if 1
    self.accountTextField = [[UITextField alloc] initWithFrame: CGRectMake(78, 98, 212, 30)];
    self.accountTextField.placeholder = @"Email";
    self.accountTextField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    self.accountTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.accountTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountTextField.returnKeyType = UIReturnKeyNext;
    
    self.passwordTextField = [[UITextField alloc] initWithFrame: CGRectMake(78, 151, 212, 30)];
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.textColor = [UIColor colorWithRed:56.0f/255.0f green:84.0f/255.0f blue:135.0f/255.0f alpha:1.0f];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    
    UILabel* accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 102, 42, 21)];
    accountLabel.text = @"账号";
    UILabel* passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(28, 155, 42, 21)];
    passwordLabel.text = @"密码";
    
    UIButton* summit = [UIButton buttonWithType: UIButtonTypeCustom];
    summit.frame = CGRectMake(137, 200, 46, 30);
    summit.backgroundColor = [UIColor redColor];
    [summit setTitle:@"登录" forState:UIControlStateNormal];
    [summit addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview: accountLabel];
    [self.view addSubview: passwordLabel];
    [self.view addSubview: self.accountTextField];
    [self.view addSubview: self.passwordTextField];
    [self.view addSubview: summit];
#endif
    
#if 0
    self.loginTableView = [[UITableView alloc] initWithFrame: CGRectMake(36, 100, 230, 100)];
    [self.view addSubview: self.loginTableView];
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

- (void)login {
    [User loginWithAccount:self.accountTextField.text andPassword:self.passwordTextField.text];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#if 0
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            
        default:
            return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellIdentifier = @"dataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        //cell.backgroundColor = [UIColor clearColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if ([indexPath section] == 0) {
            UITextField *loginTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 185, 30)];
            loginTextField.adjustsFontSizeToFitWidth = YES;
            loginTextField.textColor = [UIColor blackColor];
            if ([indexPath row] == 0) {
                loginTextField.placeholder = @"Email";
                loginTextField.keyboardType = UIKeyboardTypeEmailAddress;
                loginTextField.returnKeyType = UIReturnKeyNext;
            }
            else {
                loginTextField.placeholder = @"Password";
                loginTextField.secureTextEntry = YES;
                loginTextField.secureTextEntry = YES;
                loginTextField.returnKeyType = UIReturnKeyDone;
            }
            loginTextField.backgroundColor = [UIColor whiteColor];
            loginTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            loginTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            loginTextField.textAlignment = NSTextAlignmentLeft;
            loginTextField.tag = 0;
            //playerTextField.delegate = self;
            
            loginTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [loginTextField setEnabled: YES];
            
            //cell.textLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:loginTextField];
        }
    }
    if ([indexPath section] == 0) { // Email & Password Section
        if ([indexPath row] == 0) { // Email
            cell.textLabel.text = @"账号";
        }
        else {
            cell.textLabel.text = @"密码";
        }
    }
    else { // Login button section
        cell.textLabel.text = @"登录";
    }
    return cell;    
}
#endif

#if 0
- (UITextField*)getTextField{
    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 20, 35)];
    tf.delegate = self;
    tf.textColor        = [UIColor colorWithRed:.231 green:.337 blue:.533 alpha:1];
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    tf.borderStyle = UITextBorderStyleNone;
    tf.frame = CGRectMake(0, 20, 170, 30);
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.font = [UIFont systemFontOfSize:13];
    return tf;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
            
        default:
            return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.numberOfLines = 2;
    }
    
    if (indexPath.section == 0) {
        
        UITextField *tf = (UITextField*)cell.accessoryView;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 2;
        tf = [self getTextField];
        cell.accessoryView = cell.editingAccessoryView = tf;
        [((UITextField*)cell.accessoryView) setBorderStyle:self.loginTableView.editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone];
        [((UITextField*)cell.accessoryView) setUserInteractionEnabled:self.loginTableView.editing ? YES : NO];
        [((UITextField*)cell.accessoryView) setTextAlignment:!self.loginTableView.editing ? NSTextAlignmentRight : NSTextAlignmentLeft];
        ((UITextField*)cell.accessoryView).tag = indexPath.row;
    }
    
    return cell;
}
#endif

@end
