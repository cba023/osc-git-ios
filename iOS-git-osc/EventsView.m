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
#import "UserDetailsView.h"
#import "ProjectDetailsView.h"
//#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kKeyPrivate_token = @"private_token";
static NSString * const EventCellIdentifier = @"EventCell";

@interface EventsView ()

@property (nonatomic, strong) EventCell *prototypeCell;

@end

@implementation EventsView

@synthesize events;

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
    
    if (_privateToken) {
        events = [[NSMutableArray alloc] initWithArray:[Event getEventsWithPrivateToekn:_privateToken page:1]];
    } else {
        events = [[NSMutableArray alloc] initWithArray:[Event getUserEvents:_userId page:1]];
    }
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
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
    GLEvent *event = [self.events objectAtIndex:indexPath.row];
    [self configureCell:self.prototypeCell atIndexPath:indexPath];
    
    GLfloat descriptionHeight = _prototypeCell.eventDescription.frame.size.height,
            timeHeight = _prototypeCell.time.frame.size.height,
            totalHeight = descriptionHeight + timeHeight + 15;
    
    int totalCommitsCount = [[event.data objectForKey:@"total_commits_count"] intValue];
    if (event.data && totalCommitsCount > 0) {
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
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(EventCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    GLEvent *event = [self.events objectAtIndex:indexPath.row];

    // 删除动态添加的子视图，避免重用出错
    [cell.eventAbstract removeFromSuperview];
    
    
    [Tools setPortraitForUser:event.author view:cell.userPortrait cornerRadius:5.0];
    UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(tapPortrait:)];
    cell.userPortrait.tag = indexPath.row;
    [cell.userPortrait addGestureRecognizer:tapPortraitRecognizer];
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLEvent *event = [self.events objectAtIndex:indexPath.row];
    ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectId:event.projectId];
    [self.navigationController pushViewController:projectDetails animated:YES];
}

#pragma mark - recognizer
- (void)tapPortrait:(UITapGestureRecognizer *)sender
{
    UserDetailsView *userDetails = [UserDetailsView new];
    userDetails.user = [events objectAtIndex:((UIImageView *)sender.view).tag];
    [self.navigationController pushViewController:userDetails animated:YES];
}

- (void)refreshView:(UIRefreshControl *)refreshControl
{
    // http://stackoverflow.com/questions/19683892/pull-to-refresh-crashes-app helps a lot
    
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        [events removeAllObjects];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (_privateToken) {
                [events addObjectsFromArray:[Event getEventsWithPrivateToekn:_privateToken page:1]];
            } else {
                [events addObjectsFromArray:[Event getUserEvents:_userId page:1]];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
                [self.tableView reloadData];
                
                refreshInProgress = NO;
            });
        });
    }
}


@end
