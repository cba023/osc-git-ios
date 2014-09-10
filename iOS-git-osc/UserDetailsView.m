//
//  UserDetailsView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-1.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "UserDetailsView.h"
#import "GLGitlab.h"
#import "Tools.h"
#import "Event.h"
#import "EventsView.h"

static NSString * const EventCellId = @"EventCellId";

@interface UserDetailsView ()

@end

@implementation UserDetailsView

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
    self.title = _user.name;

    [self initSubviews];
    [self setAutoLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithUser:(GLUser *)user
{
    self = [super init];
    if (self) {
        _user = user;
    }
    return self;
}

- (void)initSubviews
{
    _portrait = [UIImageView new];
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    [Tools setPortraitForUser:_user view:_portrait cornerRadius:25.0];
    [self.view addSubview:_portrait];
    
    _name = [UILabel new];
    [_name setText:_user.name];
    [self.view addSubview:_name];
    
    _followingsCount = [UILabel new];
    [_followingsCount setText:[NSString stringWithFormat:@"Followings: %@", [_user.follow objectForKey:@"following"]]];
    [self.view addSubview:_followingsCount];
    
    _followersCount = [UILabel new];
    [_followersCount setText:[NSString stringWithFormat:@"Followers: %@", [_user.follow objectForKey:@"followers"]]];
    [self.view addSubview:_followersCount];
    
    _projects = [UILabel new];
    [_projects setText:@"Projects"];
    [self.view addSubview:_projects];
    
    _starredCount = [UILabel new];
    [_starredCount setText:[NSString stringWithFormat:@"Starred: %@", [_user.follow objectForKey:@"starred"]]];
    [self.view addSubview:_starredCount];
    
    _watchedCount = [UILabel new];
    [_watchedCount setText:[NSString stringWithFormat:@"Watches: %@", [_user.follow objectForKey:@"watched"]]];
    [self.view addSubview:_watchedCount];
    
    _eventsView = [[EventsView alloc] initWithUserID:_user.userId];
    _eventsTable = _eventsView.tableView;
    [self.view addSubview:_eventsTable];
}

- (void)setAutoLayout
{
    for (UIView *view in [self.view subviews]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[_portrait(50)]-[_name]-(8)-[_followingsCount]-(8)-[_eventsTable]-(8)-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _name, _followingsCount, _eventsTable)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[_portrait(50)]-[_starredCount]-(>=8)-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _starredCount)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(8)-[_followingsCount]-[_followersCount]-[_projects]-(8)-|"
                                                                      options:NSLayoutFormatAlignAllCenterY
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_followingsCount, _followersCount, _projects)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_starredCount]-(8)-[_watchedCount]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_starredCount, _watchedCount)]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[_eventsTable]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_eventsTable)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_portrait]-[_name]-[_followingsCount]"
                                                                      options:NSLayoutFormatAlignAllLeft
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(_portrait, _name, _followingsCount)]];
}



@end
