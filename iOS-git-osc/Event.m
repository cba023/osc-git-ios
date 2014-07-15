//
//  Event.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Event.h"
#import "GLGitLab.h"

@implementation Event

+ (NSArray *)getEventsWithPrivateToekn:(NSString *)private_token page:(int)page {
    __block BOOL done = NO;
    __block NSArray *events;
    GLGitlabSuccessBlock success = ^(id responseObject) {
        if (responseObject == nil) {
            NSLog(@"Request failed");
        } else {
            events = responseObject;
        }
        done = YES;
    };
    
    GLGitlabFailureBlock failure = ^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@, Request failed", error);
        }
        done = YES;
    };
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getEventsWithPrivateToken:private_token
                                                                                page:page
                                                                             success:success
                                                                             failure:failure];
    
    while (!done) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    return events;
}


#pragma mark - 返回event描述
#if 0
enum action {
    CREATED = 1, UPDATED, CLOSED, REOPENED, PUSHED, COMMENTED, MERGED, JOINED, LEFT, FORKED
};
#endif

+ (NSString *)getEventDescriptionWithAuthor:(NSString *)author
                                     action:(int)action
                               projectOwner:(NSString *)projectOwner
                                projectName:(NSString *)projectName
                               otherMessage:(NSString *)otherMessage
{
    NSString *eventDescription = [NSString new];
    
    NSString *authorStr = [NSString stringWithFormat: @"<font face='Arial-BoldMT' size=14 color='#0e5986'>%@</font>", author];

    
    NSArray *actions = @[@"创建了", @"更新了项目", @"关闭了项目", @"重新打开了项目", @"推送到了项目",
                         @"评论了项目", @"接受了项目", @"加入了项目", @"离开了项目", @"Fork了项目"];
    NSString *actionStr = [NSString stringWithFormat:@"<font size=14 color='#999999'>%@</font>", actions[action-1]];
    
    
    NSString *projectStr = [NSString stringWithFormat:@"<font size=14 color='#0D6DA8'>%@ / %@</font>", projectOwner, projectName];
    
    if (action > 0 && action <= 10) {
        eventDescription = [NSString stringWithFormat:@"%@ %@ %@", authorStr, actionStr, projectStr];
    } else {
        eventDescription = [NSString stringWithFormat:@"%@更新了动态", author];
    }

    return eventDescription;
}


@end
