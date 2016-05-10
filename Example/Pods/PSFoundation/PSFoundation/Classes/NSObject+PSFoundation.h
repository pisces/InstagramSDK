//
//  NSObject+PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PSFoundation_NSObject)
@property (nonatomic, readonly) BOOL dataLoading;
@property (nonatomic, readonly, getter=isFirstLoading) BOOL firstLoading;
@property (nonatomic, readonly) BOOL hasValue;
@property (nonatomic, readonly) BOOL isEmpty;
+ (id)value:(id)value;
- (void)endDataLoading;
- (BOOL)invalidDataLoading;
@end
