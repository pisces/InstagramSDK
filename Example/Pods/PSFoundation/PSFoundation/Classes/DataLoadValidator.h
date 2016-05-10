//
//  DataLoadValidator.h
//  PSFoundation
//
//  Created by pisces on 1/2/16.
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataLoadValidator : NSObject
@property (nonatomic, readonly) BOOL isFirstLoading;
- (void)endDataLoading;
- (BOOL)invalidDataLoading;
@end
