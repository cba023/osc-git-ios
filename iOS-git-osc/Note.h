//
//  Note.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-7-11.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GLIssue;

@interface Note : NSObject

+ (NSMutableArray *)getNotesForIssue:(GLIssue *)issue page:(int)page;
+ (BOOL)createNoteForIssue:(GLIssue *)issue body:(NSString *)body;

@end
