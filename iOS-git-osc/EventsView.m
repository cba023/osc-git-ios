//
//  EventsView.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLGitlab.h"
#import "EventsView.h"
#import "EventCell.h"
#import "NavigationController.h"
#import "Event.h"
#import "Tools.h"
#import "UIImageView+WebCache.h"
//#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kKeyPrivate_token = @"private_token";
static NSString * const EventCellIdentifier = @"EventCell";

@interface EventsView ()

@property (nonatomic, strong) EventCell *prototypeCell;

@end

@implementation EventsView

@synthesize eventsArray;

- (EventCell *)prototypeCell
{
    if (!_prototypeCell)
    {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:EventCellIdentifier];
    }
    return _prototypeCell;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - view life circle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"three_lines"]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:(NavigationController *)self.navigationController
                                                                            action:@selector(showMenu)];
    self.title = @"动态";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[EventCell class] forCellReuseIdentifier:EventCellIdentifier];
    
    self.eventsArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [userDefaults objectForKey:kKeyPrivate_token];
    if (privateToken == nil) {
        NSLog(@"No private_token!");
    } else {
        [self.eventsArray addObjectsFromArray:[Event getEventsWithPrivateToekn:privateToken page:1]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if 0
    GLEvent *event = [self.eventsArray objectAtIndex:indexPath.row];
    NSAttributedString *attributedStr = [Event getEventDescriptionForEvent:event];
    CGSize size = [_eventDescription sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return 60;
#else
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    
    // Need to set the width of the prototype cell to the width of the table view
    // as this will change when the device is rotated.
    
    self.prototypeCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.prototypeCell.bounds));
    
    [self.prototypeCell layoutIfNeeded];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1;
#endif
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.eventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(EventCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLEvent *event = [self.eventsArray objectAtIndex:indexPath.row];
    [cell.eventDescription setAttributedText:[Event getEventDescriptionForEvent:event]];
    
    [cell.time setAttributedText:[Tools getIntervalAttrStr:event.createdAt]];
    
    NSString *urlString = [[NSString alloc] init];
    if (event.author.portrait) {
        urlString = [NSString pathWithComponents:@[git_osc_url, event.author.portrait]];
    } else if (event.author.email) {
        urlString = [NSString stringWithFormat:@"http://secure.gravatar.com/avatar/%@?s=48&d=mm", [Tools md5:event.author.email]];
    }
    
    [cell.userPortrait sd_setImageWithURL:[NSURL URLWithString:urlString]
                         placeholderImage:[UIImage imageNamed:@"avatar"]];
}



@end
