//
//  NSArray+PSFoundation.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSArray+PSFoundation.h"

@implementation SectionedCollection
- (void)dealloc
{
    _sectionDictionary = nil;
    _sectionTokens = nil;
    _sectionKeys = nil;
    _sectionTitles = nil;
}

- (void)clear
{
    [_sectionDictionary removeAllObjects];
    [_sectionKeys removeAllObjects];
    [_sectionTitles removeAllObjects];
}

- (id)initWithTokens:(NSArray *)tokens
{
    self = [super init];
    if (self)
    {
        _sectionDictionary = [NSMutableDictionary dictionary];
        _sectionTokens = tokens;
        _sectionKeys = [NSMutableArray array];
        _sectionTitles = [NSMutableArray array];
    }
    return self;
}

- (void)divideSectionsWithList:(NSArray *)list sortKey:(NSString *)sortKey
{
    if (!list || list.count < 1)
        return;
    
    NSMutableArray *entities = [NSMutableArray arrayWithArray:list];
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES selector:@selector(sortForIndex:)];
    [entities sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
    
    for (id entity in entities)
    {
        NSString *propertyValue = [[entity valueForKey:sortKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        unichar code = [propertyValue characterAtIndex:0];
        NSInteger UniCode, index, sectionIndex;
        
        if (code < 44032)
        {
            if ((code >= 65 && code <= 90) || (code >= 97 && code <= 122))
            {
                UniCode = code - (code >= 65 && code <= 90 ? 65 : 97);
                sectionIndex = UniCode + 14;
            }
            else
            {
                sectionIndex = _sectionTokens.count - 1;
            }
        }
        else
        {
            UniCode = code - 44032;
            index = UniCode/21/28;
            sectionIndex = index;
            
            if (index >= 1) sectionIndex--;
            if (index >= 4) sectionIndex--;
            if (index >= 8) sectionIndex--;
            if (index >= 10) sectionIndex--;
            if (index >= 13) sectionIndex--;
        }
        
        NSString *sectionKey = [NSString stringWithFormat:@"%zd", sectionIndex];
        NSMutableArray *rowsInSection = [_sectionDictionary objectForKey:sectionKey];
        if (!rowsInSection)
        {
            rowsInSection = [NSMutableArray array];
            [_sectionDictionary setObject:rowsInSection forKey:sectionKey];
            [_sectionKeys addObject:sectionKey];
            [_sectionTitles addObject:[_sectionTokens objectAtIndex:sectionIndex]];
        }
        [rowsInSection addObject:entity];
    }
}
@end

@implementation NSArray (PSFoundation_NSArray)
- (NSDictionary *)indexKeyedDictionary
{
    id objectInstance;
    NSUInteger indexKey = 0;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (objectInstance in self)
        [dictionary setObject:objectInstance forKey:@(indexKey++)];
    
    return dictionary;
}

- (NSDictionary *)dictionaryWithUniqueKey:(NSString *)uniqueKey
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    for (NSDictionary *item in self)
    {
        NSMutableDictionary *newItem = [NSMutableDictionary dictionaryWithDictionary:item];
        [dictionary setObject:newItem forKeyedSubscript:[newItem objectForKey:uniqueKey]];
    }
    return dictionary;
}

- (BOOL)isEmpty
{
    return ([self count] == 0);
}

- (SectionedCollection *)sectionedCollectionWithTokens:(NSArray *)tokens sortKey:(NSString *)sortKey
{
    SectionedCollection *collection = [[SectionedCollection alloc] initWithTokens:tokens];
    [collection divideSectionsWithList:self sortKey:sortKey];
    return collection;
}

@end
