//
//  NSDictionary+w3action.m
//  w3action
//
//  Created by pisces on 2015. 8. 11..
//  Copyright (c) 2015년 Steve Kim. All rights reserved.
//

#import "NSDictionary+w3action.h"

@implementation NSDictionary (w3action_NSDictionary)
- (NSString *)JSONString {
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}
@end
