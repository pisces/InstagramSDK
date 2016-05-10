//
//  NSDictionary+w3action.m
//  w3action
//
//  Created by pisces on 2015. 8. 11..
//  Copyright (c) 2015년 Steve Kim. All rights reserved.
//

#import "NSDictionary+w3action.h"

@implementation NSDictionary (w3action_NSDictionary)

static NSString *urlEncode(NSString *string) {
    CFStringRef str = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) string, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *result = [NSString stringWithString:(__bridge NSString *) str];
    CFRelease(str);
    return result;
}

- (NSString *)JSONString {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)urlEncodedString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        id value = [self objectForKey:key];
        value = [value isKindOfClass:[NSString class]] ? urlEncode(value) : value;
        
        [parts addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, value]];
    }
    return [parts componentsJoinedByString:@"&"];
}

- (NSString *)urlString {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in self) {
        id value = [self objectForKey:key];
        
        [parts addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    return [parts componentsJoinedByString:@"&"];
}

@end