//
//  AccountManagement.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-14.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "AccountManagement.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "UIImageView+WebCache.h"

static NSString * const UserInfoCellId = @"UserInfoCell";
static NSString * const kKeyName = @"name";
static NSString * const kKeyUserPortrait = @"new_portrait";
static NSString * const kKeyFollow = @"follow";
static NSString * const kKeyWeibo = @"weibo";
static NSString * const kKeyBlog = @"blog";
static NSString * const kKeyCreatedAt = @"created_at";

@interface AccountManagement ()

@end

@implementation AccountManagement

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
    self.title = @"我的资料";
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = UIColorFromRGB(0xE0FFFF);
    
    _userDefaults = [NSUserDefaults standardUserDefaults];
    [self initSubviews];
    [self setAutoLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - About Subviews and Layout

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    NSString *portraitURL = [_userDefaults objectForKey:kKeyUserPortrait];
    [_portrait sd_setImageWithURL:[NSURL URLWithString:portraitURL]
                    placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    [Tools roundCorner:_portrait cornerRadius:5.0];
    [self.view addSubview:_portrait];
    
    _name = [UILabel new];
    [_name setText:[_userDefaults objectForKey:kKeyName]];
    [self.view addSubview:_name];
    
    _userInfo = [UITableView new];
    [_userInfo registerClass:[UITableViewCell class] forCellReuseIdentifier:UserInfoCellId];
    _userInfo.dataSource = self;
    _userInfo.delegate = self;
    [Tools roundCorner:_userInfo cornerRadius:5.0];
    [self.view addSubview:_userInfo];
    
    _logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [Tools roundCorner:_logoutButton cornerRadius:5.0];
    _logoutButton.tintColor = [UIColor whiteColor];
    _logoutButton.backgroundColor = [UIColor redColor];
    [Tools roundCorner:_logoutButton cornerRadius:5.0];
    [_logoutButton setTitle:@"注销登录" forState:UIControlStateNormal];
    [self.view addSubview:_logoutButton];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]-10-[_userInfo]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _userInfo)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-[_name]->=8-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _name)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_userInfo]-8-[_logoutButton(30)]-8-|"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_userInfo, _logoutButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_userInfo]-8-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_userInfo)]];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    } else {
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserInfoCellId forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
    
    if (indexPath.section == 0) {
        NSArray *titles = @[@"following", @"followers", @"starred", @"watched"];
        NSDictionary *follow = [_userDefaults objectForKey:kKeyFollow];
        NSString *title = [titles objectAtIndex:indexPath.row];
        NSString *count = [follow objectForKey:title];
        [label setText:[NSString stringWithFormat:@"%@ : %@", [title capitalizedString], count]];
    } else {
        switch (indexPath.row) {
            case 0: {
                NSArray *arr = [[_userDefaults objectForKey:kKeyCreatedAt] componentsSeparatedByString:@"T"];
                NSString *creatTime = [arr objectAtIndex:0];
                [label setText:[NSString stringWithFormat:@"加入时间 : %@", creatTime]];
                break;
            }
            case 1:
                [label setText:[NSString stringWithFormat:@"微博 : %@", [_userDefaults objectForKey:kKeyWeibo]]];
                break;
            case 2:
                 [label setText:[NSString stringWithFormat:@"博客 : %@", [_userDefaults objectForKey:kKeyBlog]]];
                break;
            default:
                break;
        }
    }
    [cell.contentView addSubview:label];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


@end
