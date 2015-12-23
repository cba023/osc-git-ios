//
//  GLProject.m
//  objc gitlab api
//
//  Created by Jeff Trespalacios on 1/14/14.
//  Copyright (c) 2014 Indatus. All rights reserved.
//

#import "GLProject.h"
#import "GLNamespace.h"
#import "GLUser.h"
#import "GLGitlabApi.h"

static NSString * const kKeyProjectId = @"id";
static NSString * const kKeyName = @"name";
static NSString * const kKeyPathWithNamespace = @"path_with_namespace";
static NSString * const kKeyDescription = @"description";
static NSString * const kKeyDefaultBranch = @"default_branch";
static NSString * const kKeyOwner = @"owner";
static NSString * const kKeyPublicProject = @"public";
static NSString * const kKeyPath = @"path";
#if 0
static NSString * const kKeyVisibilityLevel = @"visibility_level";
static NSString * const kKeySshUrl = @"ssh_url_to_repo";
static NSString * const kKeyHttpUrl = @"http_url_to_repo";
static NSString * const kKeyWebUrl = @"web_url";
static NSString * const kKeyNameWithNamespace = @"name_with_namespace";
static NSString * const kKeyPathWithNamespace = @"path_with_namespace";
static NSString * const kKeyWallEnabled = @"wall_enabled";
static NSString * const kKeySnippetsEnabled = @"snippets_enabled";
#endif
static NSString * const kKeyIssuesEnabled = @"issues_enabled";
static NSString * const kKeyPullRequestsEnabled = @"pull_requests_enabled";
static NSString * const kKeyWikiEnabled = @"wiki_enabled";
static NSString * const kKeyParentId = @"parent_id";
static NSString * const kKeyCreatedAt = @"created_at";
static NSString * const kKeyLastPushAt = @"last_push_at";
static NSString * const kKeyNamespace = @"namespace";
static NSString * const kKeyForksCount = @"forks_count";
static NSString * const kKeyStarsCount = @"stars_count";
static NSString * const kKeyWatchesCount = @"watches_count";
static NSString * const kKeyLanguage = @"language";
static NSString * const kKeyStarred = @"stared";
static NSString * const kKeyWatched = @"watched";
static NSString * const kKeyRecomm = @"recomm";

static NSString * const kKeyRandNumber = @"rand_num";
static NSString * const kKeyMessage = @"msg";
static NSString * const kKeyImage = @"img";

@implementation GLProject

- (instancetype)initWithJSON:(NSDictionary *)json
{
    if (self = [super init]) {
        _projectId = [json[kKeyProjectId] longLongValue];
        _projectDescription = [self checkForNull:json[kKeyDescription]];
        _defaultBranch = [self checkForNull:json[kKeyDefaultBranch]];
        _publicProject = [json[kKeyPublicProject] boolValue];
#if 0
        _visibilityLevel = [json[kKeyVisibilityLevel] intValue];
        _sshUrl = [self checkForNull:json[kKeySshUrl]];
        _httpUrl = [self checkForNull:json[kKeyHttpUrl]];
        _webUrl = [self checkForNull:json[kKeyWebUrl]];
        _pathWithNamespace = [self checkForNull:json[kKeyPathWithNamespace]];
        _nameWithNamespace = [self checkForNull:json[kKeyNameWithNamespace]];
        _wallEnabled = [json[kKeyWallEnabled] boolValue];
        _snippetsEnabled = [json[kKeySnippetsEnabled] boolValue];
#endif
        _nameSpace = [self checkForNull:json[kKeyPathWithNamespace]];
        _owner = [[GLUser alloc] initWithJSON:json[kKeyOwner]];
        _name = [self checkForNull:json[kKeyName]];
        _path = [self checkForNull:json[kKeyPath]];
        
        NSArray *names = [_nameSpace componentsSeparatedByString:@"/"];
        _nameSpace = [[NSString stringWithFormat:@"%@%%2F%@", _owner.username, names[names.count-1]] stringByReplacingOccurrencesOfString:@"." withString:@"+"];
        _issuesEnabled = [json[kKeyIssuesEnabled] boolValue];
        _pullRequestsEnabled = [json[kKeyPullRequestsEnabled] boolValue];
        _wikiEnabled = [json[kKeyWikiEnabled] boolValue];
        _parentId = [[self checkForNull:json[kKeyParentId]] longLongValue];
        _createdAt = [self checkForNull:json[kKeyCreatedAt]];
        _lastPushAt = [self checkForNull:json[kKeyLastPushAt]];
        //_createdAt = [[[GLGitlabApi sharedInstance] gitLabDateFormatter] dateFromString:json[kKeyCreatedAt]];
        //_lastPushAt = [[[GLGitlabApi sharedInstance] gitLabDateFormatter] dateFromString:json[kKeyLastPushAt]];
        _glNamespace = [[GLNamespace alloc] initWithJSON:json[kKeyNamespace]];
        _language = [self checkForNull:json[kKeyLanguage]];
        _forksCount = [json[kKeyForksCount] intValue];
        _starsCount = [json[kKeyStarsCount] intValue];
        _watchesCount = [json[kKeyWatchesCount] intValue];
        _starred = [[self checkForNull:json[kKeyStarred]] boolValue];
        _watched = [[self checkForNull:json[kKeyWatched]] boolValue];
        _recomm = [[self checkForNull:json[kKeyRecomm]] boolValue];
        
        //_randNum = [[self checkForNull:json[kKeyRandNumber]] intValue];
        _message = [self checkForNull:json[kKeyMessage]];
        _imageURL = [self checkForNull:json[kKeyImage]];
    }
    return self;
}

- (NSMutableAttributedString *)attributedLanguage
{
    if (!_attributedLanguage) {
        
        if (_language.length > 0) {
            NSTextAttachment *textAttachment = [NSTextAttachment new];
            UIImage *langImag = [UIImage imageNamed:@"language"];
            textAttachment.image = langImag;
            textAttachment.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            _attributedLanguage = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            
            [_attributedLanguage appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@   ", _language]]];
        } else {
            _attributedLanguage = [[NSMutableAttributedString alloc] init];
        }
        
        NSTextAttachment *textAttachment1 = [NSTextAttachment new];
        UIImage *langImag = [UIImage imageNamed:@"fork"];
        textAttachment1.image = langImag;
        textAttachment1.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentStr = [NSAttributedString attributedStringWithAttachment:textAttachment1];
        [_attributedLanguage appendAttributedString:attachmentStr];
        [_attributedLanguage appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %i   ", _forksCount]]];
        
        NSTextAttachment *textAttachment2 = [NSTextAttachment new];
        langImag = [UIImage imageNamed:@"star"];
        textAttachment2.image = langImag;
        textAttachment2.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment2];
        [_attributedLanguage appendAttributedString:attachmentString];
        [_attributedLanguage appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %i   ", _starsCount]]];
        
        NSTextAttachment *textAttachment3 = [NSTextAttachment new];
        langImag = [UIImage imageNamed:@"watch"];
        textAttachment3.image = langImag;
        textAttachment3.bounds = CGRectMake(0, -2, langImag.size.width, langImag.size.height);
        NSAttributedString *attachmentStrings = [NSAttributedString attributedStringWithAttachment:textAttachment3];
        [_attributedLanguage appendAttributedString:attachmentStrings];
        [_attributedLanguage appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %i", _watchesCount]]];
        
    }
    
    return _attributedLanguage;
}

- (NSMutableAttributedString *)attributedProjectName
{
    if (!_attributedProjectName) {
        NSTextAttachment *textAttachment = [NSTextAttachment new];
        if (_recomm) {
            UIImage *image = [UIImage imageNamed:@"recommend"];
            textAttachment.image = image;
            textAttachment.bounds = CGRectMake(0, -2, image.size.width, image.size.height);
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
            _attributedProjectName = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
            [_attributedProjectName appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        } else {
            _attributedProjectName = [[NSMutableAttributedString alloc] init];
        }
        [_attributedProjectName appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ / %@", self.owner.name, self.name]]];
        
    }
    return _attributedProjectName;
}


#if 0
- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToProject:other];
}
#endif

#if 0
- (BOOL)isEqualToProject:(GLProject *)project {
    if (self == project)
        return YES;
    if (project == nil)
        return NO;
    if (self.projectId != project.projectId)
        return NO;
    if (self.projectDescription != project.projectDescription && ![self.projectDescription isEqualToString:project.projectDescription])
        return NO;
    if (self.defaultBranch != project.defaultBranch && ![self.defaultBranch isEqualToString:project.defaultBranch])
        return NO;
    if (self.publicProject != project.publicProject)
        return NO;
    if (self.visibilityLevel != project.visibilityLevel)
        return NO;
    if (self.sshUrl != project.sshUrl && ![self.sshUrl isEqualToString:project.sshUrl])
        return NO;
    if (self.httpUrl != project.httpUrl && ![self.httpUrl isEqualToString:project.httpUrl])
        return NO;
    if (self.webUrl != project.webUrl && ![self.webUrl isEqualToString:project.webUrl])
        return NO;
    if (self.owner != project.owner && ![self.owner isEqualToUser:project.owner])
        return NO;
    if (self.name != project.name && ![self.name isEqualToString:project.name])
        return NO;
    if (self.nameWithNamespace != project.nameWithNamespace && ![self.nameWithNamespace isEqualToString:project.nameWithNamespace])
        return NO;
    if (self.path != project.path && ![self.path isEqualToString:project.path])
        return NO;
    if (self.pathWithNamespace != project.pathWithNamespace && ![self.pathWithNamespace isEqualToString:project.pathWithNamespace])
        return NO;
    if (self.issuesEnabled != project.issuesEnabled)
        return NO;
    if (self.pullRequestsEnabled != project.pullRequestsEnabled)
        return NO;
    if (self.wallEnabled != project.wallEnabled)
        return NO;
    if (self.wikiEnabled != project.wikiEnabled)
        return NO;
    if (self.snippetsEnabled != project.snippetsEnabled)
        return NO;
    if (self.createdAt != project.createdAt && ![self.createdAt isEqualToDate:project.createdAt])
        return NO;
    if (self.lastPushAt != project.lastPushAt && ![self.lastPushAt isEqualToDate:project.lastPushAt])
        return NO;
    if (self.glNamespace != project.glNamespace && ![self.glNamespace isEqualToGlNamespace:project.glNamespace])
        return NO;
    if (self.language != project.language && ![self.language isEqualToString:project.language])
        return NO;
    if (self.forksCount != project.forksCount)
        return NO;
    if (self.starsCount != project.starsCount)
        return NO;
    return YES;
}
#endif

- (NSUInteger)hash {
    NSUInteger hash = (NSUInteger) self.projectId;
    hash = hash * 31u + [self.projectDescription hash];
    hash = hash * 31u + [self.defaultBranch hash];
    hash = hash * 31u + self.publicProject;
    hash = hash * 31u + self.visibilityLevel;
    hash = hash * 31u + [self.sshUrl hash];
    hash = hash * 31u + [self.httpUrl hash];
    hash = hash * 31u + [self.webUrl hash];
    hash = hash * 31u + [self.owner hash];
    hash = hash * 31u + [self.name hash];
    hash = hash * 31u + [self.nameWithNamespace hash];
    hash = hash * 31u + [self.path hash];
    hash = hash * 31u + [self.pathWithNamespace hash];
    hash = hash * 31u + self.issuesEnabled;
    hash = hash * 31u + self.pullRequestsEnabled;
    hash = hash * 31u + self.wallEnabled;
    hash = hash * 31u + self.wikiEnabled;
    hash = hash * 31u + self.snippetsEnabled;
    hash = hash * 31u + [self.createdAt hash];
    hash = hash * 31u + [self.lastPushAt hash];
    hash = hash * 31u + [self.glNamespace hash];
    return hash;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.projectId=%qi", self.projectId];
    [description appendFormat:@", self.projectDescription=%@", self.projectDescription];
    [description appendFormat:@", self.defaultBranch=%@", self.defaultBranch];
    [description appendFormat:@", self.publicProject=%d", self.publicProject];
    [description appendFormat:@", self.visibilityLevel=%i", self.visibilityLevel];
    [description appendFormat:@", self.sshUrl=%@", self.sshUrl];
    [description appendFormat:@", self.httpUrl=%@", self.httpUrl];
    [description appendFormat:@", self.webUrl=%@", self.webUrl];
    [description appendFormat:@", self.owner=%@", self.owner];
    [description appendFormat:@", self.name=%@", self.name];
    [description appendFormat:@", self.nameWithNamespace=%@", self.nameWithNamespace];
    [description appendFormat:@", self.path=%@", self.path];
    [description appendFormat:@", self.pathWithNamespace=%@", self.pathWithNamespace];
    [description appendFormat:@", self.issuesEnabled=%d", self.issuesEnabled];
    [description appendFormat:@", self.pullRequestsEnabled=%d", self.pullRequestsEnabled];
    [description appendFormat:@", self.wallEnabled=%d", self.wallEnabled];
    [description appendFormat:@", self.wikiEnabled=%d", self.wikiEnabled];
    [description appendFormat:@", self.snippetsEnabled=%d", self.snippetsEnabled];
    [description appendFormat:@", self.createdAt=%@", self.createdAt];
    [description appendFormat:@", self.lastPushAt=%@", self.lastPushAt];
    [description appendFormat:@", self.glNamespace=%@", self.glNamespace];
    [description appendFormat:@", self.language=%@", self.language];
    [description appendFormat:@", self.forks_count=%i", self.forksCount];
    [description appendFormat:@", self.stars_count=%i", self.starsCount];
    [description appendString:@">"];
    return description;
}

- (NSDictionary *)jsonRepresentation
{
    //NSDateFormatter *formatter = [[GLGitlabApi sharedInstance] gitLabDateFormatter];
    //NSNull *null = [NSNull null];
    NSString *null = @"";
    
    return @{
             kKeyProjectId: @(_projectId),
             kKeyDescription: _projectDescription ?: null,
             kKeyDefaultBranch: _defaultBranch ?: null,
             kKeyPublicProject: @(_publicProject),
#if 0
             kKeyVisibilityLevel: @(_visibilityLevel),
             kKeySshUrl: _sshUrl ?: null,
             kKeyHttpUrl: _httpUrl ?: null,
             kKeyWebUrl: _webUrl ?: null,
             kKeyNameWithNamespace: _nameWithNamespace ?: null,
             kKeyPathWithNamespace: _pathWithNamespace ?: null,
             kKeyWallEnabled: @(_wallEnabled),
             kKeySnippetsEnabled: @(_snippetsEnabled),
#endif
             kKeyOwner: [_owner jsonRepresentation],
             kKeyName: _name ?: null,
             kKeyPath: _path ?: null,
             kKeyIssuesEnabled: @(_issuesEnabled),
             kKeyPullRequestsEnabled: @(_pullRequestsEnabled),
             kKeyWikiEnabled: @(_wikiEnabled),
             kKeyCreatedAt: _createdAt ?: null,                 //[formatter stringFromDate:_createdAt],
             kKeyLastPushAt: _lastPushAt ?: null,                       //[formatter stringFromDate:_lastPushAt],
             kKeyNamespace: [_glNamespace jsonRepresentation],
             kKeyForksCount: @(_forksCount),
             kKeyStarsCount: @(_starsCount),
             kKeyWatchesCount: @(_watchesCount),
             kKeyLanguage: _language ?: null,
             kKeyStarred: @(_starred),
             kKeyWatched: @(_watched),
             kKeyRecomm : @(_recomm),
             };
}

- (NSDictionary *)jsonCreateRepresentation
{
    NSNull *null = [NSNull null];
    
    return @{
             kKeyName: _name,
             kKeyDescription: _projectDescription ?: null,
             kKeyIssuesEnabled: @(_issuesEnabled),
#if 0
             kKeyWallEnabled: @(_wallEnabled),
             kKeySnippetsEnabled: @(_snippetsEnabled),
#endif
             kKeyPullRequestsEnabled: @(_pullRequestsEnabled),
             kKeyWikiEnabled: @(_wikiEnabled),
             kKeyPublicProject: @(_publicProject)
             };
}

@end
