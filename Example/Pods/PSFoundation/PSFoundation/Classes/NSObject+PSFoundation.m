//
//  NSObject+PSFoundation.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSObject+PSFoundation.h"
#import <objc/runtime.h>

@implementation NSObject (PSFoundation_NSObject)
@dynamic dataLoading, firstLoading;

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (id)value:(id)value {
    return value ? value : [NSNull null];
}

#pragma mark - Public getter/setter

- (void)setDataLoading:(BOOL)dataLoading {
    if (dataLoading == [self dataLoading])
        return;
    
    objc_setAssociatedObject(self, @"dataLoading", @(dataLoading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)dataLoading {
    return [objc_getAssociatedObject(self, @"dataLoading") boolValue];
}

- (void)setFirstLoading:(BOOL)firstLoading {
    if (firstLoading == [self isFirstLoading])
        return;
    
    objc_setAssociatedObject(self, @"firstLoading", @(firstLoading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isFirstLoading {
    id object = objc_getAssociatedObject(self, @"firstLoading");
    return object ? [object boolValue] : YES;
}

- (BOOL)isEmpty {
    return NO;
}

- (BOOL)hasValue {
    return ![self isEmpty] && ![self isKindOfClass:[NSNull class]];
}

#pragma mark - Public methods

- (void)endDataLoading {
    if (self.dataLoading) {
        self.dataLoading = NO;
        self.firstLoading = NO;
    }
}

- (BOOL)invalidDataLoading {
    if (self.dataLoading)
        return YES;
    
    self.dataLoading = YES;
    
    return NO;
}

@end
