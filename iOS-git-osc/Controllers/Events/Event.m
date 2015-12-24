//
//  Event.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "Event.h"
#import "GLGitLab.h"
#import "Tools.h"

enum action {
    CREATED = 1, UPDATED, CLOSED, REOPENED, PUSHED, COMMENTED, MERGED, JOINED, LEFT, FORKED = 11
};

@implementation Event

#pragma mark - 返回event描述

+ (NSAttributedString *)getEventDescriptionForEvent:(GLEvent *)event
{
    //NSString *eventDescription = [NSString new];
    
    UIFont *authorStrFont = [UIFont fontWithName:@"Arial-BoldMT" size:15];
    UIColor *authorStrFontColor = [UIColor colorWithRed:14/255.0 green:89/255.0 blue:134/255.0 alpha:1];
    NSDictionary *authorStrAttributes = @{NSFontAttributeName: authorStrFont,
                                          NSForegroundColorAttributeName: authorStrFontColor};
    NSMutableAttributedString *eventDescription = [[NSMutableAttributedString alloc] initWithString:event.author.name
                                                                                         attributes:authorStrAttributes];
    
    UIColor *actionFontColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
    NSDictionary *actionAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                       NSForegroundColorAttributeName: actionFontColor};
    
    UIFont *projectFont = [UIFont systemFontOfSize:15];
    UIColor *projectFontColor = [UIColor colorWithRed:13/255.0 green:109/255.0 blue:168/255.0 alpha:1];
    NSDictionary *projectAttributes = @{NSForegroundColorAttributeName: projectFontColor,
                                        NSFontAttributeName: projectFont};
    NSAttributedString *project = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", event.project.owner.name, event.project.name]
                                                                     attributes:projectAttributes];
    
    enum action actionType = event.action;
    NSMutableAttributedString *action = [NSMutableAttributedString alloc];
    switch (actionType) {
        case CREATED: 
            action = [action initWithString:@" 在项目  创建了 " attributes:actionAttributes];
            [action insertAttributedString:project atIndex:5];
            [action appendAttributedString:[[NSAttributedString alloc] initWithString:[self eventTitle:event.events]
                                                                           attributes:projectAttributes]];
            break;
        
        case UPDATED:
             action = [action initWithString:@" 更新了项目 " attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        
        case CLOSED:
            action = [action initWithString:@" 关闭了项目  的 " attributes:actionAttributes];
            [action insertAttributedString:project atIndex:7];
            [action appendAttributedString:[[NSAttributedString alloc]initWithString:[self eventTitle:event.events]
                                                                          attributes:projectAttributes]];
            break;
        case REOPENED:
            action = [action initWithString:@" 重新打开了项目  的 " attributes:actionAttributes];
            [action insertAttributedString:project atIndex:9];
            [action appendAttributedString:[[NSAttributedString alloc]initWithString:[self eventTitle:event.events]
                                                                          attributes:projectAttributes]];
            break;
        case PUSHED:
            action = [action initWithString:@" 推送到了项目  的分支" attributes:actionAttributes];
            [action insertAttributedString:project atIndex:8];//event.eventData.ref
            [action insertAttributedString:[[NSAttributedString alloc] initWithString:[[event.data valueForKey:@"ref"] lastPathComponent]
                                                                           attributes:projectAttributes]
                                   atIndex:action.length-2];
            break;
        case COMMENTED: {
            action = [action initWithString:@" 评论了项目  的 " attributes:actionAttributes];
            [action insertAttributedString:project atIndex:7];
            [action appendAttributedString:[[NSAttributedString alloc]initWithString:[self eventTitle:event.events]
                                                                          attributes:projectAttributes]];
            break;
        }
        case MERGED:
            action = [action initWithString:@" 接受了项目  的 " attributes:actionAttributes];
            [action insertAttributedString:project atIndex:7];
            [action appendAttributedString:[[NSAttributedString alloc]initWithString:[self eventTitle:event.events]
                                                                          attributes:projectAttributes]];
            break;
        case JOINED:
            action = [action initWithString:@" 加入了项目 " attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        case LEFT:
            action = [action initWithString:@" 离开了项目 " attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        case FORKED:
            action = [action initWithString:@" Fork了项目 " attributes:actionAttributes];
            [action appendAttributedString:project];
            break;
        default:
            action = [action initWithString:@" 更新了动态" attributes:actionAttributes];
            break;
    }
    
    [eventDescription appendAttributedString:action];
    
    return eventDescription;
}

+ (NSString *)eventTitle:(NSDictionary *)events
{
    NSString *eventTitle;
    if ([[events objectForKey:@"pull_request"] count] > 0) {
        NSString *iid = [[events objectForKey:@"pull_request"] objectForKey:@"iid"];
        eventTitle = [NSString stringWithFormat:@"Pull Request #%@", iid];
    } else if ([[events objectForKey:@"issue"] count] > 0) {
        NSString *iid = [[events objectForKey:@"issue"] objectForKey:@"iid"];
        eventTitle = [NSString stringWithFormat:@"Issue #%@", iid];
    } else {
        eventTitle = @"";
    }

    return eventTitle;
}

+ (NSString *)eventContent:(NSDictionary *)events
{
    NSString *eventContent;
    if ([[events objectForKey:@"pull_request"] count] > 0) {
        eventContent = [[events objectForKey:@"pull_request"] objectForKey:@"title"];
    } else if ([[events objectForKey:@"issue"] count] > 0) {
        eventContent = [[events objectForKey:@"issue"] objectForKey:@"title"];
    } else {
        eventContent = @"";
    }
    
    return eventContent;
}


+ (NSAttributedString *)generateEventAbstract:(GLEvent *)event
{
    NSDictionary *idStrAttributes = @{
                                      NSForegroundColorAttributeName:UIColorFromRGB(0x0d6da8),
                                      NSFontAttributeName:[UIFont systemFontOfSize:14]
                                      };
    NSDictionary *digestAttributes = @{
                                       NSForegroundColorAttributeName:UIColorFromRGB(0x303030),
                                       //NSForegroundColorAttributeName:UIColorFromRGB(0x999999),
                                       NSFontAttributeName:[UIFont systemFontOfSize:14]
                                       };
    NSMutableAttributedString *digest = [NSMutableAttributedString new];
    int totalCommitsCount = [[event.data objectForKey:@"total_commits_count"] intValue];//(int)event.eventData.totalCommitCount;//
    
    int digestsCount = 0;
    while (totalCommitsCount > 0) {
//        GLCommit * commit = [event.eventData.dataCommits objectAtIndex:digestsCount];
        
        NSString *commitId = [[[[event.data objectForKey:@"commits"] objectAtIndex:digestsCount] valueForKey:@"id"] substringToIndex:9];
        NSString *message = [[[event.data objectForKey:@"commits"] objectAtIndex:digestsCount] valueForKey:@"message"];
        
        NSString *commitAuthorName = [[[[event.data objectForKey:@"commits"] objectAtIndex:digestsCount] objectForKey:@"author"] objectForKey:@"name"];//commit.author.name;//
        message = [NSString stringWithFormat:@" %@ - %@", commitAuthorName, message];
        [digest appendAttributedString:[[NSAttributedString alloc] initWithString:commitId attributes:idStrAttributes]];
        [digest appendAttributedString:[[NSAttributedString alloc] initWithString:message attributes:digestAttributes]];
        
        if (++digestsCount == totalCommitsCount || digestsCount >= 2) {break;}
        [digest appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
    }
    if (totalCommitsCount > 2) {
        NSString *moreCommitsNotice = [NSString stringWithFormat:@"\n\n... and %i more commits", totalCommitsCount - 2];
        [digest appendAttributedString:[[NSAttributedString alloc] initWithString:moreCommitsNotice
                                                                       attributes:digestAttributes]];
    }
    
    return digest;
}

+ (void)setAbstractContent:(UITextView *)textView forEvent:(GLEvent *)event
{
    enum action actionType = event.action;
    
    NSDictionary *digestAttributes = @{
                                       NSForegroundColorAttributeName:UIColorFromRGB(0x303030),
                                       NSFontAttributeName:[UIFont systemFontOfSize:14]
                                       };

    int totalCommitsCount = 0;
    if (event.data.count > 0) {
        totalCommitsCount = [[event.data objectForKey:@"total_commits_count"] intValue];//(int)event.eventData.totalCommitCount;
    }
    if (totalCommitsCount > 0) {
        textView.backgroundColor = [UIColor whiteColor];
        [textView setAttributedText:[self generateEventAbstract:event]];
    } else if (actionType == COMMENTED) {
        textView.backgroundColor = [Tools uniformColor];
        NSString *comment = [Tools flattenHTML:[[event.events objectForKey:@"note"] objectForKey:@"note"]];

        comment = comment.length ? comment : @" ";
        comment = [comment stringByTrimmingCharactersInSet: [NSCharacterSet newlineCharacterSet]];

        [textView setAttributedText:[[NSAttributedString alloc] initWithString:comment attributes:digestAttributes]];
    } else if (actionType == MERGED) {
        textView.backgroundColor = [Tools uniformColor];
        NSString *content = [Event eventContent:event.events];
        [textView setAttributedText:[[NSAttributedString alloc] initWithString:content attributes:digestAttributes]];
    } else if (actionType == CREATED) {
        textView.backgroundColor = [Tools uniformColor];
        NSString *title = [NSString new];
        if ([event.targetType isEqualToString:@"PullRequest"]) {
            title = [[event.events objectForKey:@"pull_request"] objectForKey:@"title"];
        } else if ([event.targetType isEqualToString:@"Issue"]) {
            title = [[event.events objectForKey:@"issue"] objectForKey:@"title"];
        }
        [textView setAttributedText:[[NSAttributedString alloc] initWithString:title attributes:digestAttributes]];
    } else {
        textView.backgroundColor = [Tools uniformColor];
        textView.text = @"";
        textView.font = [UIFont systemFontOfSize:0];
    }
}



@end
