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
    if([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0)
    {
        self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x145096);
    } else {
        [self.navigationController.navigationBar setTintColor:UIColorFromRGB(0x3A5FCD)];
    }

    self.title = @"动态";
    NSDictionary *navbarTitleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:navbarTitleTextAttributes];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
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
    [self configureCell:self.prototypeCell forRowAtIndexPath:indexPath];
    GLfloat descriptionHeight = _prototypeCell.eventDescription.frame.size.height,
            timeHeight = _prototypeCell.time.frame.size.height,
            totalHeight = descriptionHeight + timeHeight + 15;
    if ([_prototypeCell.eventAbstract isDescendantOfView:_prototypeCell.contentView]) {
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
    
    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(EventCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLEvent *event = [self.eventsArray objectAtIndex:indexPath.row];
    

    cell.eventDescription.frame = CGRectMake(49, 5, 251, 30);
    [cell.eventDescription setAttributedText:[Event getEventDescriptionForEvent:event]];
    
    CGFloat fixedWidth = cell.eventDescription.frame.size.width;
    CGSize newSize = [cell.eventDescription sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = cell.eventDescription.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    cell.eventDescription.frame = newFrame;
    
    cell.eventDescription.backgroundColor = [UIColor clearColor];
    cell.eventDescription.scrollEnabled = NO;
    cell.eventDescription.editable = NO;
    cell.eventDescription.selectable = NO;
    cell.eventDescription.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:cell.eventDescription];

    
    if (event.data) {
        cell.eventAbstract = [self createEventAbstractView:event];
        CGFloat width = 260;
        CGSize size = [cell.eventDescription sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        cell.eventAbstract.frame = CGRectMake(49, 10+newSize.height, fmaxf(size.width, width), size.height);
        //[Tools roundCorner:eventAbstractView];
        [cell.contentView addSubview:cell.eventAbstract];
        
        cell.time.frame = CGRectMake(63, newSize.height+size.height+15, 158, 20);
    } else {
        cell.time.frame = CGRectMake(63, newSize.height+10, 158, 20);
    }
    
    cell.time.textAlignment = NSTextAlignmentLeft;
    [cell.time setAttributedText:[Tools getIntervalAttrStr:event.createdAt]];
    [cell.contentView addSubview:cell.time];
    
    [Tools setPortraitForUser:event.author view:cell.userPortrait];
}

#pragma mark - 初始化子视图
- (UITextView *)createEventAbstractView:(GLEvent *)event
{
    UITextView *eventAbstractView = [UITextView new];
    
    NSDictionary *idStrAttributes = @{NSForegroundColorAttributeName:UIColorFromRGB(0x0d6da8)};
    NSDictionary *digestAttributes = @{NSForegroundColorAttributeName:UIColorFromRGB(0x999999)};
    NSString *commitId = [[[[[event data] objectForKey:@"commits"] objectAtIndex:0] objectForKey:@"id"] substringToIndex:9];
    NSString *message = [[[[event data] objectForKey:@"commits"] objectAtIndex:0] objectForKey:@"message"];
    
    message = [NSString stringWithFormat:@" %@ - %@", event.author.name, message];
    NSMutableAttributedString *digest = [[NSMutableAttributedString alloc] initWithString:commitId attributes:idStrAttributes];
    [digest appendAttributedString:[[NSAttributedString alloc] initWithString:message attributes:digestAttributes]];
    
    [eventAbstractView setAttributedText:digest];
    eventAbstractView.selectable = NO;
    eventAbstractView.scrollEnabled = NO;
    
    return eventAbstractView;
}


@end
