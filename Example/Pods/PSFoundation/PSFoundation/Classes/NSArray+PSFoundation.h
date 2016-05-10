//
//  NSArray+PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+PSFoundation.h"

@interface SectionedCollection : NSObject
@property (atomic, strong) NSMutableDictionary *sectionDictionary;
@property (atomic, strong) NSArray *sectionTokens;
@property (atomic, strong) NSMutableArray *sectionKeys;
@property (atomic, strong) NSMutableArray *sectionTitles;
- (void)clear;
- (void)divideSectionsWithList:(NSArray *)list sortKey:(NSString *)sortKey;
@end

@interface NSArray (PSFoundation_NSArray)
- (NSDictionary *)indexKeyedDictionary;
- (NSDictionary *)dictionaryWithUniqueKey:(NSString *)uniqueKey;
- (SectionedCollection *)sectionedCollectionWithTokens:(NSArray *)tokens sortKey:(NSString *)sortKey;
@end
