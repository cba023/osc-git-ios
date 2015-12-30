//
//  CacheProjectsUtil.m
//  Git@OSC
//
//  Created by 李萍 on 15/12/21.
//  Copyright © 2015年 chenhaoxiang. All rights reserved.
//

#import "CacheProjectsUtil.h"
#import <FMDB.h>

static NSString * const insertUser = @"INSERT OR IGNORE INTO User"
                                     @"(user_id, name, portrait_url)"
                                     @"VALUES (?, ?, ?);";
static NSString * const insertProject = @"INSERT OR IGNORE INTO Project"
                                        @"(id, userId, name, description, path_with_namespace, language, forks_count, stars_count, watches_count, recomm, projectsType)"
                                        @"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";

static NSString * const insertLanguage = @"INSERT OR IGNORE INTO Language"
                                         @"(id, name) VALUES (?, ?);";



@interface CacheProjectsUtil ()

@property (nonatomic, strong) FMDatabase *dataBase;
@property (nonatomic, copy) NSString *path;

@end

@implementation CacheProjectsUtil

// 创建数据库
+(instancetype)shareInstance
{
    static CacheProjectsUtil *cache;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        cache = [CacheProjectsUtil new];
        
        NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        cache.path = [docsDirectory stringByAppendingPathComponent:@"GitProject.sqlite"];
        cache.dataBase = [FMDatabase databaseWithPath:cache.path];
        
        [cache createUser];
        [cache createProjects];
        
        [cache createLanguages];
    });
    
    return cache;
}
#pragma mark - 创建用户数据表
- (void)createUser
{
    if ([_dataBase open]) {
        NSString * sql = @"CREATE TABLE IF NOT EXISTS User"
                         @"("
                         @"user_id INTEGER PRIMARY KEY NOT NULL,"
                         @"name TEXT,"
                         @"portrait_url TEXT"
                         @")";
        
        [_dataBase executeUpdate:sql];
        
        [_dataBase close];
    }
}


#pragma mark - 创建项目数据表
-(void)createProjects
{
    if ([_dataBase open]) {//id,name,description,path_with_namespace,forks_count,language,stars_count,watches_count,recomm,projectsType
        NSString *sql = @"CREATE TABLE IF NOT EXISTS Project"
                        @"("
                        @"id INTEGER PRIMARY KEY NOT NULL,"
                        @"userId INTEGER,"
                        @"name TEXT,"
                        @"description TEXT,"
                        @"path_with_namespace TEXT,"
                        @"language TEXT,"
                        @"forks_count INTEGER,"
                        @"stars_count INTEGER,"
                        @"watches_count INTEGER,"
                        @"recomm BOOL,"
                        @"projectsType INTEGER"
                        @")";
        
        [_dataBase executeUpdate:sql];
        [_dataBase close];
    }
}

-(void)insertProjectList:(NSArray *)projects andProjectType:(ProjectsType)projectType
{
    if ([_dataBase open]) {
        for (GLProject * project in projects) {
            [self p_insertProject:project andProjectType:projectType];
        }
        
        [_dataBase close];
    }
}

-(void)p_insertProject:(GLProject *)project andProjectType:(ProjectsType)projectType
{
    [_dataBase executeUpdate:insertProject,
                @(project.projectId),
                @(project.owner.userId),
                project.name,
                project.projectDescription,
                project.nameSpace,
                project.language,
                @(project.forksCount),
                @(project.starsCount),
                @(project.watchesCount),
                @(project.recomm),
                @(projectType)
                ];
    
    [_dataBase executeUpdate:insertUser,
                 @(project.owner.userId),
                 project.owner.name,
                 project.owner.portrait
                 ];

}

-(NSArray *)readProjectListWithProjectType:(ProjectsType)projectType
{
    NSMutableArray *projects = [NSMutableArray new];
    
    if ([_dataBase open]) {
        NSString *sql = [NSString stringWithFormat:
                                                 @"SELECT * FROM Project WHERE projectsType=%lu",
                                                (unsigned long)projectType];
        FMResultSet *result = [_dataBase executeQuery:sql];
        
        while ([result next]) {
            GLProject *project = [GLProject new];
            
            project.projectId = [result intForColumn:@"id"];
            project.name = [result stringForColumn:@"name"];
            project.projectDescription = [result stringForColumn:@"description"];
            
            project.nameSpace = [result stringForColumn:@"path_with_namespace"];// componentsSeparatedByString:@"%2F"][1]
            project.language = [result stringForColumn:@"language"];
            project.forksCount = [result intForColumn:@"forks_count"];
            
            project.starsCount = [result intForColumn:@"stars_count"];
            project.watchesCount = [result intForColumn:@"watches_count"];
            project.recomm = [result boolForColumn:@"recomm"];
            
            NSInteger userid = [result intForColumn:@"userId"];
            project.owner = [self readUser:userid];
            
            [projects addObject:project];
        }
    }
    
    return projects;
}

#pragma mark read user

- (GLUser *)readUser:(NSInteger)userID
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM User WHERE user_id = %ld;", (long)userID];
    
    FMResultSet *result = [_dataBase executeQuery:sql];
    GLUser *user = [GLUser new];
    
    if ([result next]) {
        user.userId = [result intForColumn:@"user_id"];
        user.name = [result stringForColumn:@"name"];
        user.portrait = [result stringForColumn:@"portrait_url"];
    }
    
    return user;
}

#pragma mark - 创建语言数据表
-(void)createLanguages
{
    if ([_dataBase open]) {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS Language"
                        @"("
                        @"id INTEGER PRIMARY KEY NOT NULL,"
                        @"name TEXT"
                        @");";
        
        [_dataBase executeUpdate:sql];
        
        [_dataBase close];
    }
}

-(void)insertLanguageList:(NSArray *)languages
{
    if ([_dataBase open]) {
        for (GLLanguage * language in languages) {
            [_dataBase executeUpdate:insertLanguage,
                                     @(language.languageID),
                                     language.name
             ];
            
            
        }
        
        [_dataBase close];
    }
}

- (NSArray *)readLanguageList
{
    NSMutableArray *languages = [NSMutableArray new];
    
    if ([_dataBase open]) {
        FMResultSet *result = [_dataBase executeQuery:@"SELECT * FROM Language"];
        
        while ([result next]) {
            GLLanguage *language = [GLLanguage new];
            
            language.languageID = [result intForColumn:@"id"];
            language.name = [result stringForColumn:@"name"];
            
            [languages addObject:language];
        }
    }
    return languages;
}

#pragma mark - 清除缓存列表
- (void)removeCache
{
    if ([_dataBase open]) {
        [_dataBase executeUpdate:@"DELETE FROM Language"];
        [_dataBase executeUpdate:@"DELETE FROM User"];
        [_dataBase executeUpdate:@"DELETE FROM Project"];
        
        [_dataBase close];
    }
    
}

@end
