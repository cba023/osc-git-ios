//
//  GLGitlab.h
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/22/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef objc_gitlab_api_GLGitlab_h
    #define objc_gitlab_api_GLGitlab_h

    #import "GLConstants.h"

    #import "GLGitlabApi.h"
    #import "GLGitlabApi+Commits.h"
    #import "GLGitLabApi+Events.h"
    #import "GLGitlabApi+Files.h"
    #import "GLGitlabApi+Issues.h"
    #import "GLGitlabApi+MergeRequest.h"
    #import "GLGitlabApi+Milestones.h"
    #import "GLGitlabApi+Notes.h"
    #import "GLGitlabApi+Projects.h"
    #import "GLGitlabApi+Repositories.h"
    #import "GLGitlabApi+Session.h"
    #import "GLGitlabApi+Snippets.h"
    #import "GLGitlabApi+Users.h"

    #import "GLBranch.h"
    #import "GLCommit.h"
    #import "GLEvent.h"
    #import "GLDiff.h"
    #import "GLFile.h"
    #import "GLBlob.h"
    #import "GLIssue.h"
    #import "GLMergeRequest.h"
    #import "GLMilestone.h"
    #import "GLNamespace.h"
    #import "GLNote.h"
    #import "GLProject.h"
    #import "GLSnippet.h"
    #import "GLTag.h"
    #import "GLUser.h"
    #import "GLLanguage.h"

    #define git_osc_url @"https://git.oschina.net"       //@"http://192.168.1.117"
#endif
