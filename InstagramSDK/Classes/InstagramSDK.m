//
//  InstagramSDK.m
//  InstagramSDK
//
//  Created by pisces on 2016. 5. 3..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "InstagramSDK.h"

@implementation InstagramSDK
+ (NSBundle *)bundle {
    return [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"InstagramSDK" ofType:@"bundle"]];
}

+ (NSString *)localizedStringForKey:(NSString *)key table:(NSString *)table {
    return [[self bundle] localizedStringForKey:key value:nil table:table];
}
@end
