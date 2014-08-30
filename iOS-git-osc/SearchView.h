//
//  SearchView.h
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-21.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProjectsTableController;

@interface SearchView : UIViewController <UISearchBarDelegate>

@property NSMutableArray *projects;

@property UISearchBar *searchBar;
@property ProjectsTableController *resultsTableController;
@property UITableView *results;

@property BOOL isLoading;
@property BOOL isLoadOver;

@end
