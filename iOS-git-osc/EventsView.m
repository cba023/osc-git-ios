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
    
#if 0
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
    {
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x145096);
    } else {
        [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0x3A5FCD)];
    }

    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
#endif
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
}

- (void)dealloc
{
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLEvent *event = [self.eventsArray objectAtIndex:indexPath.row];
    [self configureCell:self.prototypeCell withEvent:event];
    
    GLfloat descriptionHeight = _prototypeCell.eventDescription.frame.size.height,
            timeHeight = _prototypeCell.time.frame.size.height,
            totalHeight = descriptionHeight + timeHeight + 15;
    if (event.data) {
        totalHeight += _prototypeCell.eventAbstract.frame.size.height + 5;
    }

    return totalHeight;
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
    
    GLEvent *event = [self.eventsArray objectAtIndex:indexPath.row];
    [self configureCell:cell withEvent:event];
    
    return cell;
}

- (void)configureCell:(EventCell *)cell withEvent:(GLEvent *)event
{
    // 删除动态添加的子视图，避免重用出错
    [cell.eventAbstract removeFromSuperview];
    
    
    [Tools setPortraitForUser:event.author view:cell.userPortrait];
    
    [cell generateEventDescriptionView:event];
    [cell.contentView addSubview:cell.eventDescription];
    GLfloat descriptionHeight = cell.eventDescription.frame.size.height;
    int totalCommitsCount = [[event.data objectForKey:@"total_commits_count"] intValue];

    if (event.data && totalCommitsCount > 0) {
        cell.eventAbstract = [UITextView new];
        [cell generateEventAbstractView:event];
        [cell.contentView addSubview:cell.eventAbstract];
        CGFloat width = 260;
        CGSize size = [cell.eventAbstract sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        cell.eventAbstract.frame = CGRectMake(49, 6+descriptionHeight, fmaxf(size.width, width), size.height);
        
        cell.time.frame = CGRectMake(53, descriptionHeight+size.height+9, 158, 20);
    } else {
        cell.time.frame = CGRectMake(53, descriptionHeight+6, 158, 20);
    }
    
    [cell.time setAttributedText:[Tools getIntervalAttrStr:event.createdAt]];
    [cell.contentView addSubview:cell.time];
}



@end
