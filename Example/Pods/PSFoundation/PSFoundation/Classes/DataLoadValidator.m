//
//  DataLoadValidator.m
//  PSFoundation
//
//  Created by pisces on 1/2/16.
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "DataLoadValidator.h"

@implementation DataLoadValidator
{
@private
    BOOL dataLoading;
    BOOL firstLoading;
}

- (id)init {
    self = [super init];
    
    if (self) {
        firstLoading = YES;
    }
    
    return self;
}

- (void)endDataLoading {
    dataLoading = NO;
    firstLoading = NO;
}

- (BOOL)invalidDataLoading {
    if (dataLoading)
        return YES;
    
    dataLoading = YES;
    
    return NO;
}

- (BOOL)isFirstLoading {
    return firstLoading;
}

@end
