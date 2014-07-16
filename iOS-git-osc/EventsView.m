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
static NSString * const cellId = @"EventCell";

@interface EventsView ()

@end

@implementation EventsView

@synthesize eventsArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    [self.tableView registerClass:[EventCell class] forCellReuseIdentifier:cellId];
    
    self.eventsArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *privateToken = [userDefaults objectForKey:kKeyPrivate_token];
    if (privateToken == nil) {
        NSLog(@"No private_token!");
    } else {
        [self.eventsArray addObjectsFromArray:[Event getEventsWithPrivateToekn:privateToken page:1]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    GLEvent *event = [self.eventsArray objectAtIndex:indexPath.row];
    [cell.eventDescription setText:[Event getEventDescriptionWithAuthor:event.author.name
                                                                  action:event.action
                                                            projectOwner:event.project.owner.name
                                                             projectName:event.project.name
                                                            otherMessage:@""]];
    
    [cell.time setText:[Tools intervalSinceNow:event.createdAt]];
    
    NSString *urlString = [[NSString alloc] init];
    if (event.author.portrait) {
        urlString = [NSString stringWithFormat:@"%@%@%@", git_osc_url, @"//", event.author.portrait];
    } else if (event.author.email) {
        urlString = [NSString stringWithFormat:@"http://secure.gravatar.com/avatar/%@?s=48&d=mm", [Tools md5:event.author.email]];
    }
    
    [cell.userPortrait sd_setImageWithURL:[NSURL URLWithString:urlString]
                         placeholderImage:[UIImage imageNamed:@"avatar"]];
    
    
    return cell;
}



@end
