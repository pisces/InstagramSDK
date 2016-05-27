//
//  AbstractModel.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "AbstractModel.h"
#import "PSFoundation.h"

NSString *const kModelDidChangePropertiesNotification = @"kModelDidChangePropertiesNotification";
NSString *const kModelDidSynchronizeNotification = @"kModelDidSynchronizeNotification";

@interface AbstractModel ()
@property (readwrite, strong) NSDictionary *sourceObject;
@end

@implementation AbstractModel

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Abstract methods

- (void)dealloc {
    self.sourceObject = nil;
}

- (id)body {
    return nil;
}

- (id)childWithKey:(NSString *)key classType:(Class)classType {
    return nil;
}

- (id)childWithKey:(NSString *)key classType:(Class)classType map:(void (^)(AbstractModel *result))map {
    return nil;
}

- (id)childWithArray:(NSArray *)array classType:(Class)classType {
    return nil;
}

- (id)childWithArray:(NSArray *)array classType:(Class)classType map:(void (^)(AbstractModel *model))map {
    return nil;
}

- (void)synchronizeSource {
}

- (void)updateProperties:(NSDictionary *)dictionary {
}

#pragma mark - Public methods

- (NSDictionary *)dictionary {
    return [self dictionaryWithExcludes:nil];
}

- (NSDictionary *)dictionaryWithExcludes:(NSArray *)excludes {
    NSDictionary *properties = [self classProperties];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSString *key in properties) {
        if ([key isEqualToString:@"sourceObject"] ||
            (excludes && [excludes indexOfObject:key] != NSNotFound))
            continue;
        
        id value = [self valueForKey:key];
        if (value && ![value isKindOfClass:[NSNull class]] && ![value isKindOfClass:[NSAttributedString class]])
            [dict setObject:[self unformat:[self dictionaryWithValue:value] forKey:key] forKey:key];
    }
    
    return dict;
}

- (void)didChangeProperties {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self synchronizeSource];
        
        dispatch_async_main_queue(^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kModelDidChangePropertiesNotification object:self];
        });
    });
}

- (id)format:(id)value forKey:(NSString *)key {
    Class class = [self classOfPropertyNamed:key];
    
    if (class == [NSString class])
        return [NSString stringWithFormat:@"%@", value];
    
    if (class == [NSNumber class]) {
        if ([value isKindOfClass:[NSNull class]])
            return nil;
        
        id orgValue = [self valueForKey:key];
        NSString *typeString = @([orgValue objCType]);
        
        if (!typeString)
            return value;
        
        if ([typeString isEqualToString:@"c"] ||
            [typeString isEqualToString:@"B"])
            return @([value boolValue]);
        
        if ([typeString isEqualToString:@"i"])
            return @([value integerValue]);
        
        if ([typeString isEqualToString:@"s"])
            return @([value shortValue]);
        
        if ([typeString isEqualToString:@"l"])
            return @([value longValue]);
        
        if ([typeString isEqualToString:@"q"])
            return @([value longLongValue]);
        
        if ([typeString isEqualToString:@"I"])
            return @([value unsignedIntegerValue]);
        
        if ([typeString isEqualToString:@"L"])
            return @([value unsignedLongValue]);
        
        if ([typeString isEqualToString:@"Q"])
            return @([value unsignedLongLongValue]);
        
        if ([typeString isEqualToString:@"f"])
            return @([value floatValue]);
        
        if ([typeString isEqualToString:@"d"])
            return @([value doubleValue]);
    }
    
    return value;
}

/**
 * @constructor
 */
- (instancetype)initWithObject:(id)object {
    self = [super init];
    
    if (self)
        [self setProperties:object];
    
    return self;
}

- (BOOL)isEqualToModel:(AbstractModel *)other {
    return [self.dictionary isEqualToDictionary:other.dictionary];
}

- (void)equals:(AbstractModel *)other block:(void (^)(BOOL))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL equal = [self isEqualToModel:other];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            block(equal);
        });
    });
}

- (void)setProperties:(id)object {
    self.sourceObject = object;
}

- (void)synchronize:(AbstractModel *)other {
    [self synchronize:other completion:nil postEnabled:NO];
}

- (void)synchronize:(AbstractModel *)other postEnabled:(BOOL)postEnabled {
    [self synchronize:other completion:nil postEnabled:postEnabled];
}

- (void)synchronize:(AbstractModel *)other completion:(void(^)(void))completion {
    [self synchronize:other completion:completion postEnabled:NO];
}

- (void)synchronize:(AbstractModel *)other completion:(void(^)(void))completion postEnabled:(BOOL)postEnabled {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSArray *keys = [[self classProperties] allKeys];
            
            for (NSString *key in keys) {
                @try {
                    id value = [other valueForKey:key];
                    [self setValue:value forKey:key];
                }
                @catch (NSException *exception) {}
            }
        }
        
        dispatch_async_main_queue(^{
            if (postEnabled)
                [[NSNotificationCenter defaultCenter] postNotificationName:kModelDidSynchronizeNotification object:self];
            
            if (completion)
                completion();
        });
    });
}

- (NSString *)toString {
    return [self description];
}

- (NSString *)toSourceString {
    return [self.sourceObject description];
}

- (id)unformat:(id)value forKey:(NSString *)key {
    return value;
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (Class)classOfPropertyNamed:(NSString *)propertyName {
    Class propertyClass = nil;
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
    
    if (property) {
        NSString *propertyAttributes = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
        NSArray *splitPropertyAttributes = [propertyAttributes componentsSeparatedByString:@","];
        
        if (splitPropertyAttributes.count > 0) {
            NSString *encodeType = splitPropertyAttributes[0];
            NSArray *splitEncodeType = [encodeType componentsSeparatedByString:@"\""];
            NSString *className = splitEncodeType[1];
            propertyClass = NSClassFromString(className);
        }
    }
    
    return propertyClass;
}

- (id)dictionaryWithValue:(id)value {
    if ([value isKindOfClass:[AbstractModel class]])
        return ((AbstractModel *) value).dictionary;
    
    if ([value isKindOfClass:[NSArray class]]) {
        NSArray *rawArray = (NSArray *) value;
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:rawArray.count];
        
        for (id object in rawArray)
            [array addObject:[self dictionaryWithValue:object]];
        
        return array;
    }
    
    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *rawDict = (NSDictionary *) value;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:rawDict.count];
        
        for (NSString *key in rawDict)
            [dict setObject:[self dictionaryWithValue:[rawDict valueForKey:key]] forKey:key];
        
        return dict;
    }
    
    return value;
}

- (BOOL)isEqualWithArray:(NSArray *)array other:(NSArray *)other {
    NSUInteger count = [array count];
    NSUInteger otherCount = [other count];
    
    if (count != otherCount)
        return NO;
    
    if (count == 0)
        return YES;
    
    for (NSInteger i=0; i<count; i++) {
        id object = array[i];
        id otherObject = other[i];
        
        if (![self isEqualWithValue:object otherValue:otherObject])
            return NO;
    }
    
    return YES;
}

- (BOOL)isEqualWithDictionary:(NSDictionary *)dictionary other:(NSDictionary *)other {
    NSUInteger count = [dictionary count];
    NSUInteger otherCount = [other count];
    
    if (count != otherCount)
        return NO;
    
    if (count == 0)
        return YES;
    
    for (NSString *key in dictionary) {
        id object = [dictionary valueForKey:key];
        id otherObject = [other valueForKey:key];
        
        if (![self isEqualWithValue:object otherValue:otherObject])
            return NO;
    }
    
    return YES;
}

- (BOOL)isEqualWithValue:(id)value otherValue:(id)otherValue {
    if (!value && !otherValue)
        return YES;
    if ((value && !otherValue) || (!value && otherValue))
        return NO;
    if ([value isEqual:otherValue])
        return YES;
    if ([value isKindOfClass:[AbstractModel class]])
        return [value isEqualToModel:otherValue];
    if ([value isKindOfClass:[NSArray class]])
        return [self isEqualWithArray:value other:otherValue];
    if ([value isKindOfClass:[NSDictionary class]])
        return [self isEqualWithDictionary:value other:otherValue];
    if ([value isKindOfClass:[NSString class]])
        return [value isEqualToString:otherValue];
    if ([value isKindOfClass:[NSData class]])
        return [value isEqualToData:otherValue];
    if ([value isKindOfClass:[NSDate class]])
        return [value isEqualToDate:otherValue];
    if ([value isKindOfClass:[NSNumber class]])
        return [value isEqualToNumber:otherValue];
    if ([value isKindOfClass:[NSValue class]])
        return [value isEqualToValue:otherValue];
    if ([value isKindOfClass:[NSValue class]])
        return [value isEqualToValue:otherValue];
    if ([value isKindOfClass:[NSTimeZone class]])
        return [value isEqualToTimeZone:otherValue];
    if ([value isKindOfClass:[NSSet class]])
        return [value isEqualToSet:otherValue];
    if ([value isKindOfClass:[NSAttributedString class]])
        return [value isEqualToAttributedString:otherValue];
    if ([value isKindOfClass:[NSHashTable class]])
        return [value isEqualToHashTable:otherValue];
    if ([value isKindOfClass:[NSOrderedSet class]])
        return [value isEqualToOrderedSet:otherValue];
    return NO;
}

@end
