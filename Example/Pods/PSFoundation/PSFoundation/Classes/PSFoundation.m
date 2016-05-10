//
//  PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Modified by Steve Kim on 2016. 5. 9..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "PSFoundation.h"

@implementation PSFoundation

// ================================================================================================
//  Public
// ================================================================================================

+ (NSBundle *)bundle {
    return [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"PSFoundation" ofType:@"bundle"]];
}

+ (NSString *)imageName:(NSString *)name {
    return [@"PSFoundation.bundle" stringByAppendingFormat:@"/%@", name];
}

+ (NSString *)localizedStringWithKey:(NSString *)key {
    return [[self bundle] localizedStringForKey:key value:@"" table:@"PSFoundation"];
}

@end

void dispatch_async_main_queue(dispatch_block_t block) {
    if ([[NSThread currentThread] isEqual:[NSThread mainThread]])
        block();
    else
        dispatch_async(dispatch_get_main_queue(), block);
}

void dispatch_sync_main_queue(dispatch_block_t block) {
    if ([[NSThread currentThread] isEqual:[NSThread mainThread]])
        block();
    else
        dispatch_sync(dispatch_get_main_queue(), block);
}