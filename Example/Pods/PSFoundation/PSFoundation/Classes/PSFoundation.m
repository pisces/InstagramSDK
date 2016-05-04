//
//  PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 Steve Kim. All rights reserved.
//

/*
 Copyright 2015 Steve Kim
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

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