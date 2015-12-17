//
//  GLProject.h
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/14/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLBaseObject.h"
#import "GLUser.h"
#import "GLNamespace.h"

@interface GLProject : GLBaseObject

// id
@property (nonatomic, assign) int64_t projectId;
// name
@property (nonatomic, copy) NSString *name;
// description
@property (nonatomic, copy) NSString *projectDescription;
// default branch
@property (nonatomic, copy) NSString *defaultBranch;
// owner
@property (nonatomic, strong) GLUser *owner;
// public
@property (nonatomic, assign, getter=isPublicProject) BOOL publicProject;
// visibility_level
@property (nonatomic, assign) int32_t visibilityLevel;
// ssh_url_to_repo
@property (nonatomic, copy) NSString *sshUrl;
// http_url_to_repo
@property (nonatomic, copy) NSString *httpUrl;
// web_url
@property (nonatomic, copy) NSString *webUrl;
// name_with_namespace
@property (nonatomic, copy) NSString *nameWithNamespace;
// path
@property (nonatomic, copy) NSString *path;
// path_with_namespace
@property (nonatomic, copy) NSString *pathWithNamespace;
// issues_enabled
@property (nonatomic, assign, getter=areIssuesEnabled) BOOL issuesEnabled;
// merge_requests_enabled
@property (nonatomic, assign, getter=arePullRequestsEnabled) BOOL pullRequestsEnabled;
// wall_enabled
@property (nonatomic, assign, getter=isWallEnabled) BOOL wallEnabled;
// wiki_enabled
@property (nonatomic, assign, getter=isWikiEnabled) BOOL wikiEnabled;
// snippets_enabled
@property (nonatomic, assign, getter=areSnippetsEnabled) BOOL snippetsEnabled;
// parent_id
@property (nonatomic, assign) int64_t parentId;
// created_at
@property (nonatomic, copy) NSString *createdAt;
// last_activity_at
@property (nonatomic, copy) NSString *lastPushAt;
// namespace
@property (nonatomic, strong) GLNamespace *glNamespace;
// language
@property (nonatomic, copy) NSString *language;
// forks_count
@property (nonatomic, assign) int32_t forksCount;
// stars_count
@property (nonatomic, assign) int32_t starsCount;
// watches_count
@property (nonatomic, assign) int32_t watchesCount;
// starred
@property (nonatomic, assign, getter = isStarred) BOOL starred;
// watched
@property (nonatomic, assign, getter = isWatched) BOOL watched;
// recomm
@property (nonatomic, assign, getter = isRecomm) BOOL recomm;

@property (nonatomic, copy) NSString *nameSpace;

@property (nonatomic, strong) NSMutableAttributedString *attributedLanguage;
@property (nonatomic, strong) NSMutableAttributedString *attributedProjectName;


#pragma mark - 奖品信息

// rand_num
//@property (nonatomic, assign) NSUInteger randNum;
// msg
@property (nonatomic, copy) NSString *message;
// img
@property (nonatomic, copy) NSString *imageURL;

//- (BOOL)isEqualToProject:(GLProject *)project;

@end
