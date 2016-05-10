//
//  AbstractJSONModel.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "AbstractJSONModel.h"

@implementation AbstractJSONModel

// ================================================================================================
//  Overridden: AbstractModel
// ================================================================================================

#pragma mark - Overridden: AbstractModel

- (id)body
{
    return [self dictionaryRepresentation];
}

- (id)childWithKey:(NSString *)key classType:(Class)classType
{
    return [self childWithKey:key classType:classType map:NULL];
}

- (id)childWithKey:(NSString *)key classType:(Class)classType map:(void (^)(AbstractModel *result))map
{
    id object = [self.sourceObject objectForKey:key];
    AbstractModel *model = nil;
    
    if (object && [classType isSubclassOfClass:[AbstractModel class]])
    {
        if ([object isKindOfClass:[NSDictionary class]])
        {
            model = [[classType alloc] initWithObject:object];
            
            if (map)
                map(model);
            
            return model;
        }
        
        if ([object isKindOfClass:[NSArray class]])
        {
            NSArray *rawArray = (NSArray *)object;
            NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:rawArray.count];
            
            for (id obj in rawArray)
            {
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    model = [[classType alloc] initWithObject:obj];
                    [resultArray addObject:model];
                    
                    if (map)
                        map(model);
                }
                else if ([obj isKindOfClass:[NSArray class]])
                    [resultArray addObject:[self childWithArray:obj classType:classType map:map]];
            }
            
            return resultArray;
        }
        
    }
    return nil;
}

- (id)childWithArray:(NSArray *)array classType:(Class)classType
{
    return [self childWithArray:array classType:classType map:NULL];
}

- (id)childWithArray:(NSArray *)array classType:(Class)classType map:(void (^)(AbstractModel *model))map
{
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[array count]];
    
    if ([classType isSubclassOfClass:[AbstractModel class]])
    {
        for (id obj in array)
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                AbstractModel *model = [[classType alloc] initWithObject:obj];
                [resultArray addObject:model];
                
                if (map)
                    map(model);
            }
            else if ([obj isKindOfClass:[NSArray class]])
                [resultArray addObject:[self childWithArray:obj classType:classType map:map]];
        }
    }
    
    return resultArray;
}

- (void)setProperties:(id)object
{
    if (![object isKindOfClass:[NSDictionary class]])
        return;
    
    [super setProperties:object];
    
    NSDictionary *json = (NSDictionary *)object;
    
    for (NSString *key in json) {
        @try {
            @autoreleasepool {
                id value = object[key];
                
                if (value && ![value isKindOfClass:[NSNull class]])
                    [self setValue:[self format:value forKey:key] forKey:key];
            }
        }
        @catch (NSException *exception) {
            if ([exception.name isEqualToString:NSInvalidArgumentException]) {
                NSNumber *boolVal = [NSNumber numberWithBool:[object[key] boolValue]];
                [self setValue:boolVal forKey:key];
            }
        }
    }
}

- (void)synchronizeSource
{
    if (![self.sourceObject isKindOfClass:[NSMutableDictionary class]])
        return;
    
    NSArray *keys = [[self classProperties] allKeys];
    
    for (NSString *key in keys)
        [self synchronizeSourceWithKey:key];
}

- (NSString *)toSourceString
{
    return [self JSONString];
}

/**
 * @implementaion
 */
- (void)updateProperties:(NSDictionary *)dictionary
{
    if (self.sourceObject && [self.sourceObject isKindOfClass:[NSMutableDictionary class]])
    {
        for (NSString *key in dictionary) {
            @try {
                [self setValue:[self format:dictionary[key] forKey:key] forKey:key];
                [self.sourceObject setValue:dictionary[key] forKeyPath:key];
            }
            @catch (NSException *exception) {}
        }
    }
    else
    {
        [self setProperties:dictionary];
    }
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public methods

- (void)synchronizeSourceWithKey:(NSString *)key
{
    if (![self.sourceObject isKindOfClass:[NSMutableDictionary class]])
        return;
    
    @try {
        @autoreleasepool {
            id value = [self valueForKey:key];
            
            if (value) {
                if ([value isKindOfClass:[AbstractJSONModel class]])
                    [value synchronizeSource];
                else if (![value isKindOfClass:[AbstractModel class]])
                    [self.sourceObject setValue:[self format:value forKey:key] forKey:key];
            }
        }
    }
    @catch (NSException *exception) {}
}

@end
