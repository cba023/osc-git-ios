//
//  Event.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Event.h"
#import "GLGitLab.h"

enum action {
    CREATED = 1, UPDATED, CLOSED, REOPENED, PUSHED, COMMENTED, MERGED, JOINED, LEFT, FORKED
};

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

+ (NSArray *)getUserEvent:(int64_t)userId page:(int)page
{
    __block BOOL done = NO;
    __block NSMutableArray *events;
    
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
    
    GLNetworkOperation *op = [[GLGitlabApi sharedInstance] getUserEvents:userId
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
+ (NSString *)getEventDescriptionForEvent:(GLEvent *)event
{
    NSString *eventDescription = [NSString new];
    
    NSString *author = [NSString stringWithFormat: @"<font face='Arial-BoldMT' size=14 color='#0e5986'>%@</font>", event.author.name];
    
    NSString *actionFormat = @"<font size=14 color='#999999'>%@</font>";
    NSString *action = [NSString new];
    NSString *branch = [[event.data objectForKey:@"ref"] lastPathComponent];
    
    NSString *project = [NSString stringWithFormat:@"<font size=14 color='#0D6DA8'>%@ / %@</font>", event.project.owner.name, event.project.name];
    
    enum action actionType = event.action;
    switch (actionType) {
        case CREATED:
            action = [NSString stringWithFormat:@"在项目%@创建了%@", project, event.targetType];
            break;
        case UPDATED:
            action = [NSString stringWithFormat:@"更新了项目%@", project];
            break;
        case CLOSED:
            action = [NSString stringWithFormat:@"关闭了项目%@", project];
            break;
        case REOPENED:
            action = [NSString stringWithFormat:@"重新打开了项目%@", project];
            break;
        case PUSHED:
            action = [NSString stringWithFormat:@"推送到了项目%@的%@", project, branch];
            break;
        case COMMENTED:
            action = [NSString stringWithFormat:@"评论了项目%@的%@", project, event.targetType];
            break;
        case MERGED:
            action = [NSString stringWithFormat:@"接受了项目%@的%@", project, event.targetType];
            break;
        case JOINED:
            action = [NSString stringWithFormat:@"加入了项目%@", project];
            break;
        case LEFT:
            action = [NSString stringWithFormat:@"离开了项目%@", project];
            break;
        case FORKED:
            action = [NSString stringWithFormat:@"FORK了项目%@", project];
            break;
        default:
            break;
    }

    if (event.action > 0 && event.action <= 10) {
        eventDescription = [NSString stringWithFormat:@"%@ %@", author, action];
    } else {
        eventDescription = [NSString stringWithFormat:@"%@更新了动态", author];
    }
    
    return eventDescription;
}

#else

+ (NSAttributedString *)getEventDescriptionForEvent:(GLEvent *)event
{
    //NSString *eventDescription = [NSString new];
    
    UIFont *authorStrFont = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    UIColor *authorStrFontColor = [UIColor colorWithRed:14/255.0 green:89/255.0 blue:134/255.0 alpha:1];
    NSDictionary *authorStrAttributes = @{NSFontAttributeName: authorStrFont,
                                          NSForegroundColorAttributeName: authorStrFontColor};
    NSMutableAttributedString *eventDescription = [[NSMutableAttributedString alloc] initWithString:event.author.name
                                                                                         attributes:authorStrAttributes];
    
    UIFont *actionFont = [UIFont fontWithName:@"STHeitiSC-Medium" size:15];
    UIColor *actionFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    NSDictionary *actionAttributes = @{NSFontAttributeName: actionFont,
                                       NSForegroundColorAttributeName: actionFontColor};
    
    UIColor *projectFontColor = [UIColor colorWithRed:13/255.0 green:109/255.0 blue:168/255.0 alpha:1];
    NSDictionary *projectAttributes = @{NSForegroundColorAttributeName: projectFontColor};
    NSAttributedString *project = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", event.project.owner.name, event.project.name]
                                                                     attributes:projectAttributes];
    
    enum action actionType = event.action;
    NSMutableAttributedString *action = [NSMutableAttributedString alloc];
    switch (actionType) {
        case CREATED: 
            action = [action initWithString:@"在项目创建了" attributes:actionAttributes];
            [action insertAttributedString:project atIndex:2];
            [action appendAttributedString:[[NSAttributedString alloc] initWithString:event.targetType
                                                                           attributes:projectAttributes]];
            break;
        
        case UPDATED:
             action = [action initWithString:@"更新了项目" attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        
        case CLOSED:
            action = [action initWithString:@"关闭了项目" attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        case REOPENED:
            action = [action initWithString:@"重新打开了项目" attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        case PUSHED:
            action = [action initWithString:@"推送到了项目的分支" attributes:actionAttributes];
            [action insertAttributedString:project atIndex:6];
            [action insertAttributedString:[[NSAttributedString alloc] initWithString:[[event.data objectForKey:@"ref"] lastPathComponent]
                                                                           attributes:actionAttributes]
                                   atIndex:action.length-2];
            break;
        case COMMENTED:
            action = [action initWithString:@"评论了项目的" attributes:actionAttributes];
            [action insertAttributedString:project atIndex:5];
            [action appendAttributedString:[[NSAttributedString alloc]initWithString:event.targetType
                                                                          attributes:projectAttributes]];
            break;
        case MERGED:
            action = [action initWithString:@"接受了项目的" attributes:actionAttributes];
            [action insertAttributedString:project atIndex:5];
            [action appendAttributedString:[[NSAttributedString alloc]initWithString:event.targetType
                                                                          attributes:projectAttributes]];
            break;
        case JOINED:
            action = [action initWithString:@"加入了项目" attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        case LEFT:
            action = [action initWithString:@"离开了项目" attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        case FORKED:
            action = [action initWithString:@"FORK了项目" attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        default:
            break;
    }
    
    if (event.action > 0 && event.action <= 10) {
        [eventDescription appendAttributedString:action];
    } else {
        [eventDescription appendAttributedString:[[NSAttributedString alloc] initWithString:@"更新了动态"
                                                                                 attributes:actionAttributes]];
    }
    
    return eventDescription;
}
#endif


@end
