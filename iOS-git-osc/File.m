//
//  File.m
//  iOS-git-osc
//
//  Created by chenhaoxiang on 14-9-8.
//  Copyright (c) 2014年 chenhaoxiang. All rights reserved.
//

#import "File.h"

@implementation File

+ (NSArray *)codeFileSuffixes
{
    static NSArray *_codeFileSuffixes;
    static dispatch_once_t codeFileSuffixesToken;
    dispatch_once(&codeFileSuffixesToken, ^{
        _codeFileSuffixes = @[
                             @"java", @"confg", @"ini", @"xml", @"json", @"txt", @"go",
                             @"php", @"php3", @"php4", @"php5", @"js", @"css", @"html",
                             @"properties", @"c", @"hpp", @"h", @"hh", @"cpp", @"cfg",
                             @"rb", @"example", @"gitignore", @"project", @"classpath",
                             @"mm", @"md", @"rst", @"vm", @"cl", @"py", @"pl", @"haml",
                             @"erb", @"scss", @"bat", @"coffee", @"as", @"sh", @"m", @"pas",
                             @"cs", @"groovy", @"scala", @"sql", @"bas", @"xml", @"vb",
                             @"xsl", @"swift", @"ftl", @"yml", @"ru", @"jsp", @"markdown",
                             @"cshap", @"apsx", @"sass", @"less", @"ftl", @"haml", @"log",
                             @"tx", @"csproj", @"sln", @"clj", @"scm", @"xhml", @"xaml",
                             @"lua", @"pch"
                             ];

    });
    
    return _codeFileSuffixes;
}

+ (NSArray *)specialFileNames
{
    static NSArray *_specialFileNames;
    static dispatch_once_t fileNamesToken;
    dispatch_once(&fileNamesToken, ^{
        _specialFileNames = @[
                             @"LICENSE", @"README", @"readme", @"makefile", @"gemfile",
                             @"gemfile.*", @"gemfile.lock", @"TODO", @"CHANGELOG"
                             ];
        
    });
    
    return _specialFileNames;
}

+ (NSArray *)imageSuffixes
{
    static NSArray *_imageSuffixes;
    static dispatch_once_t imageSuffixToken;
    dispatch_once(&imageSuffixToken, ^{
        _imageSuffixes = @[
                           @"png", @"jpg", @"jpeg", @"jpe", @"bmp", @"exif", @"dxf",
                           @"wbmp", @"ico", @"jpe", @"gif", @"pcx", @"fpx", @"ufo",
                           @"tiff", @"svg", @"eps", @"ai", @"tga", @"pcd", @"hdri"
                           ];
    });
    
    return _imageSuffixes;
    
}

+ (NSString *)getFileNameSuffix:(NSString *)fileName
{
    return [[[fileName componentsSeparatedByString:@"."] lastObject] lowercaseString];
}

+ (BOOL)isCodeFile:(NSString *)fileName
{
    NSString *fileSuffix = [self getFileNameSuffix:fileName];
    for (NSString *suffix in [self codeFileSuffixes]) {
        if ([fileSuffix isEqualToString:suffix]) {
            return YES;
        }
    }
    
    for (NSString *specialFileName in [self specialFileNames]) {
        if ([fileName isEqualToString:specialFileName]) {
            return YES;
        }
    }
    
    return NO;
}

+ (BOOL)isImage:(NSString *)fileName
{
    NSString *fileSuffix = [self getFileNameSuffix:fileName];
    for (NSString *imageSuffix in [self imageSuffixes]) {
        if ([imageSuffix isEqualToString:fileSuffix]) {
            return YES;
        }
    }
    
    return NO;
}



@end
