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
#import "LastCell.h"

static NSString * const kKeyPrivate_token = @"private_token";
static NSString * const EventCellIdentifier = @"EventCell";

@interface EventsView ()

@property int64_t userID;
@property NSString *privateToken;

@property BOOL isFinishedLoad;
@property BOOL isLoading;
@property BOOL isFirstRequest;
@property LastCell *lastCell;

@end

@implementation EventsView

@synthesize events;

- (id)initWithPrivateToken:(NSString *)privateToken
{
    self = [super init];
    if (self) {
        _privateToken = privateToken;
    }
    
    return self;
}

- (id)initWithUserID:(int64_t)userID
{
    self = [super init];
    if (self) {
        _userID = userID;
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
    self.tableView.backgroundColor = [Tools uniformColor];
    UIView *footer =[[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = footer;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    events = [NSMutableArray new];
    _lastCell = [[LastCell alloc] initCell];
    _isFinishedLoad = NO;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (events.count > 0) {
        return;
    }
    
    if (_privateToken && [Tools isPageCacheExist:9]) {
        [self loadFromCache];
        return;
    }
    
    _isFirstRequest = YES;
    [_lastCell loading];
    [self loadMore];
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
    if (indexPath.row < events.count) {
        GLEvent *event = [self.events objectAtIndex:indexPath.row];
        
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        
        [label setAttributedText:[Event getEventDescriptionForEvent:event]];
        CGFloat descriptionHeight = [label sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 60, MAXFLOAT)].height;
        
        CGFloat abstractHeight = 0;
        UITextView *textView = [UITextView new];
        textView.editable = NO;
        textView.scrollEnabled = NO;
        int totalCommitsCount = 0;
        if (![event.data isEqual:@""]) {
            totalCommitsCount = [[event.data objectForKey:@"total_commits_count"] intValue];
        }
        if (totalCommitsCount > 0) {
            [textView setAttributedText:[Event generateEventAbstract:event]];
        }
        abstractHeight = [textView sizeThatFits:CGSizeMake(self.tableView.frame.size.width - 60, MAXFLOAT)].height;
        
        //CGFloat staticHeight = totalCommitsCount > 0? 47: 39;
        
        return descriptionHeight + abstractHeight + 47;
    } else {
        return 60;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return events.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < events.count) {
        EventCell *cell = [tableView dequeueReusableCellWithIdentifier:EventCellIdentifier forIndexPath:indexPath];
        
        GLEvent *event = [self.events objectAtIndex:indexPath.row];
        
        [Tools setPortraitForUser:event.author view:cell.userPortrait cornerRadius:5.0];
        UITapGestureRecognizer *tapPortraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                action:@selector(tapPortrait:)];
        cell.userPortrait.tag = indexPath.row;
        [cell.userPortrait addGestureRecognizer:tapPortraitRecognizer];
        
        [cell generateEventDescriptionView:event];
        
        [cell.time setAttributedText:[Tools getIntervalAttrStr:event.createdAt]];
        
        int totalCommitsCount = 0;
        if (![event.data isEqual:@""]) {
            totalCommitsCount = [[event.data objectForKey:@"total_commits_count"] intValue];
        }
        if (totalCommitsCount > 0) {
            [cell.eventAbstract setAttributedText:[Event generateEventAbstract:event]];
        } else {
            [cell.eventAbstract setText:@""];
        }
        
        return cell;        
    } else {
        return _lastCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GLEvent *event = [self.events objectAtIndex:indexPath.row];
    ProjectDetailsView *projectDetails = [[ProjectDetailsView alloc] initWithProjectID:event.projectId];
    [self.navigationController pushViewController:projectDetails animated:YES];
}

#pragma mark - recognizer
- (void)tapPortrait:(UITapGestureRecognizer *)sender
{
    GLUser *user = [events objectAtIndex:((UIImageView *)sender.view).tag];
    UserDetailsView *userDetails = [[UserDetailsView alloc] initWithPrivateToken:nil userID:user.userId];
    [self.navigationController pushViewController:userDetails animated:YES];
}

#pragma mark - 上拉加载更多

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    // 下拉到最底部时显示更多数据
	if(scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height)))
	{
        [self loadMore];
	}
}

#pragma mark - 从缓存加载

- (void)loadFromCache
{
    [_lastCell loading];
    
    [events removeAllObjects];
    _isFinishedLoad = NO;
    
    [events addObjectsFromArray:[Tools getPageCache:9]];
    _isFinishedLoad = events.count < 20;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
    });
}



#pragma mark - 刷新

- (void)refresh
{
    static BOOL refreshInProgress = NO;
    
    if (!refreshInProgress)
    {
        refreshInProgress = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadEventsOnPage:1 refresh:YES];
            refreshInProgress = NO;
        });
    }
}

- (void)loadMore
{
    if (_isFinishedLoad || _isLoading) {return;}
    
    _isLoading = YES;
    [_lastCell loading];
    
    [self loadEventsOnPage:events.count/20 + 1 refresh:NO];
}




- (void)loadEventsOnPage:(NSUInteger)page refresh:(BOOL)refresh
{
    if (![Tools isNetworkExist]) {
        if (refresh) {
            [self.refreshControl endRefreshing];
        } else {
            [_lastCell empty];
        }
        [Tools toastNotification:@"错误 无网络连接" inView:self.view];
        return;
    }

    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            if (refresh) {
                [self.refreshControl endRefreshing];
                [events removeAllObjects];
            }
            
            _isFinishedLoad = [(NSArray *)responseObject count] < 20;
            
            NSUInteger repeatedCount = [Tools numberOfRepeatedEvents:events event:[responseObject objectAtIndex:0]];
            [events addObjectsFromArray:[responseObject subarrayWithRange:NSMakeRange(repeatedCount, 20-repeatedCount)]];

            if (_privateToken && (refresh || _isFirstRequest)) {
                [Tools savePageCache:responseObject type:9];
                _isFirstRequest = NO;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                _isFinishedLoad? [_lastCell finishedLoad]: [_lastCell normal];
            });
        }
        _isLoading = NO;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        } else {
            NSLog(@"error == nil");
        }
        if (refresh) {
            [self.refreshControl endRefreshing];
        }
        _isLoading = NO;
    };
    
    if (_privateToken) {
        [[GLGitlabApi sharedInstance] getEventsWithPrivateToken:_privateToken page:page success:success failure:failure];
    } else {
        [[GLGitlabApi sharedInstance] getUserEvents:_userID page:page success:success failure:failure];
    }
}



@end
