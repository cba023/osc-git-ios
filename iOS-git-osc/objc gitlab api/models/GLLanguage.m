//
//  GLLanguage.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-8-22.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "GLLanguage.h"

static NSString * const kKeyLanguageID = @"id";
static NSString * const kKeyName = @"name";
static NSString * const kKeyIdent = @"ident";
static NSString * const kKeyOrder = @"order";
static NSString * const kKeyParentID = @"parent_id";
static NSString * const kKeyProjectsCount = @"projects_count";
static NSString * const kKeyCreatedAt = @"created_at";
static NSString * const kKeyUpdatedAt = @"updated_at";


@implementation GLLanguage

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _languageID = [json[kKeyLanguageID] integerValue];
        _name = [self checkForNull:json[kKeyName]];
        _ident = [self checkForNull:json[kKeyIdent]];
        _order = [json[kKeyOrder] integerValue];
        _parentID = [json[kKeyParentID] integerValue];
        _projectsCount = [json[kKeyProjectsCount] integerValue];
        _createdAt = [self checkForNull:json[kKeyCreatedAt]];
        _updatedAt = [self checkForNull:json[kKeyUpdatedAt]];
    }
    return self;
}

- (NSDictionary *)jsonRepresentation
{
    NSNull *null = [NSNull null];
    
    return @{
             kKeyLanguageID:    @(_languageID),
             kKeyName:          _name ?: null,
             kKeyIdent:         _ident ?: null,
             kKeyOrder:         @(_order),
             kKeyParentID:      @(_parentID),
             kKeyProjectsCount: @(_projectsCount),
             kKeyCreatedAt:     _createdAt ?: null,
             kKeyUpdatedAt:     _updatedAt ?: null
             };
}


@end
