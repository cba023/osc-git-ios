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

#import "AppDelegate.h"
#import "MainViewController.h"

static NSString * const FollowCellId = @"FollowCell";
static NSString * const SocialCellId = @"SocialCell";

static NSString * const kKeyUserId = @"id";
static NSString * const kKeyUsername = @"username";
static NSString * const kKeyName = @"name";
static NSString * const kKeyBio = @"bio";
static NSString * const kKeyWeibo = @"weibo";
static NSString * const kKeyBlog = @"blog";
static NSString * const kKeyThemeId = @"theme_id";
static NSString * const kKeyCreatedAt = @"created_at";
static NSString * const kKeyState = @"state";
static NSString * const kKeyPortrait = @"new_portrait";
static NSString * const kKeyPrivateToken = @"private_token";
static NSString * const kKeyAdmin = @"is_admin";
static NSString * const kKeyCanCreateGroup = @"can_create_group";
static NSString * const kKeyCanCreateProject = @"can_create_project";
static NSString * const kKeyCanCreateTeam = @"can_create_team";
static NSString * const kKeyFollow = @"follow";

@interface AccountManagement ()

@end

@implementation AccountManagement

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"我的资料";
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [Tools uniformColor];
    
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
    NSString *portraitURL = [_userDefaults objectForKey:kKeyPortrait];
    [_portrait sd_setImageWithURL:[NSURL URLWithString:portraitURL]
                 placeholderImage:[UIImage imageNamed:@"tx"]];
    
    [Tools roundView:_portrait cornerRadius:5.0];
    [self.view addSubview:_portrait];
    
    _name = [UILabel new];
    _name.backgroundColor = [UIColor clearColor];
    [_name setText:[_userDefaults objectForKey:kKeyName]];
    [self.view addSubview:_name];
    
    _follow = [UITableView new];
    [_follow registerClass:[UITableViewCell class] forCellReuseIdentifier:FollowCellId];
    _follow.dataSource = self;
    _follow.delegate = self;
    _follow.separatorStyle = UITableViewCellSeparatorStyleNone;
    _follow.scrollEnabled = NO;
    [Tools roundView:_follow cornerRadius:5.0];
    [self.view addSubview:_follow];
    
    _social = [UITableView new];
    [_social registerClass:[UITableViewCell class] forCellReuseIdentifier:SocialCellId];
    _social.dataSource = self;
    _social.delegate = self;
    _social.separatorStyle = UITableViewCellSeparatorStyleNone;
    _social.scrollEnabled = NO;
    [Tools roundView:_social cornerRadius:5.0];
    [self.view addSubview:_social];
    
    _logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //_logoutButton.tintColor = [UIColor whiteColor];
    _logoutButton.backgroundColor = [UIColor redColor];
    [Tools roundView:_logoutButton cornerRadius:5.0];
    [_logoutButton setTitle:@"注销登录" forState:UIControlStateNormal];
    _logoutButton.titleLabel.font = [UIFont systemFontOfSize:17];
    [_logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_logoutButton];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-8-[_portrait(36)]-15-[_follow]"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _follow)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_portrait(36)]-[_name]->=8-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _name)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_follow(130)]-15-[_social(100)]-30-[_logoutButton(40)]"
                                                                      options:NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllRight
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_follow, _social, _logoutButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-8-[_follow]-8-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_follow)]];
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _follow) {
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
    UITableViewCell *cell;
    if (tableView == _follow) {
        cell = [tableView dequeueReusableCellWithIdentifier:FollowCellId forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:SocialCellId forIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 9, 254, 21)];
    label.textColor = [UIColor grayColor];
    
    if (tableView == _follow) {
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
            case 1: {
                NSString *weibo = [_userDefaults objectForKey:kKeyWeibo]?: @"";
                [label setText:[NSString stringWithFormat:@"微博 : %@", weibo]];
                break;
            }
            case 2: {
                NSString *blog = [_userDefaults objectForKey:kKeyBlog]?: @"";
                [label setText:[NSString stringWithFormat:@"博客 : %@", blog]];
                break;
            }
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
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

#pragma mark - logout
- (void)logout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kKeyPrivateToken];
    [userDefaults removeObjectForKey:kKeyUserId];
    [userDefaults removeObjectForKey:kKeyUsername];
    [userDefaults removeObjectForKey:kKeyName];
    [userDefaults removeObjectForKey:kKeyBio];
    [userDefaults removeObjectForKey:kKeyWeibo];
    [userDefaults removeObjectForKey:kKeyBlog];
    [userDefaults removeObjectForKey:kKeyThemeId];
    [userDefaults removeObjectForKey:kKeyState];
    [userDefaults removeObjectForKey:kKeyCreatedAt];
    [userDefaults removeObjectForKey:kKeyPortrait];
    [userDefaults removeObjectForKey:kKeyPrivateToken];
    [userDefaults removeObjectForKey:kKeyAdmin];
    [userDefaults removeObjectForKey:kKeyCanCreateGroup];
    [userDefaults removeObjectForKey:kKeyCanCreateProject];
    [userDefaults removeObjectForKey:kKeyCanCreateTeam];
    [userDefaults removeObjectForKey:kKeyFollow];
    
    // 删除用户动态及项目的缓存
    NSUserDefaults *cache = [NSUserDefaults standardUserDefaults];
    for (int i = 3; i < 6; i++) {
        NSString *key = [NSString stringWithFormat:@"type-%d", i];
        [cache removeObjectForKey:key];
    }
    [cache removeObjectForKey:@"type-9"];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = [MainViewController new];

}


@end
