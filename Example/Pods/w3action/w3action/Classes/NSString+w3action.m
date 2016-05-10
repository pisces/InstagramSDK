//
//  NSString+w3action.m
//  w3action
//
//  Created by Steve Kim on 2013. 12. 30..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSString+w3action.h"

@implementation NSString (w3action_NSString)
+ (NSString *)stringWithData:(NSData *)data {
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)urlParameters {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [self componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters)
    {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        NSString *key = [[parts objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([parts count] > 1)
        {
            id value = [[parts objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [result setObject:value forKey:key];
        }
    }
    return result;
}
@end
