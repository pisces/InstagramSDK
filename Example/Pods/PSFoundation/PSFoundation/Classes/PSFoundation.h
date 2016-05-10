//
//  PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Modified by Steve Kim on 2016. 5. 9..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ext.h"
#import "model.h"

@interface PSFoundation : NSObject
+ (NSBundle *)bundle;
+ (NSString *)imageName:(NSString *)name;
+ (NSString *)localizedStringWithKey:(NSString *)key;
@end

#ifdef __BLOCKS__
__OSX_AVAILABLE_STARTING(__MAC_10_6,__IPHONE_4_0)
DISPATCH_EXPORT DISPATCH_NONNULL_ALL DISPATCH_NOTHROW
void
dispatch_async_main_queue(dispatch_block_t block);
#endif

#ifdef __BLOCKS__
__OSX_AVAILABLE_STARTING(__MAC_10_6,__IPHONE_4_0)
DISPATCH_EXPORT DISPATCH_NONNULL_ALL DISPATCH_NOTHROW
void
dispatch_sync_main_queue(dispatch_block_t block);
#endif