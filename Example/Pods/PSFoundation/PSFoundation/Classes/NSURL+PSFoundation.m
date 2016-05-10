//
//  NSURL+PSFoundation.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSURL+PSFoundation.h"

@implementation NSURL (PSFoundation_NSURL)

// ================================================================================================
//  Public
// ================================================================================================

- (BOOL)isCurrentURLScheme
{
    for (NSDictionary *urlType in [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"])
    {
        for (NSString *scheme in [urlType objectForKey:@"CFBundleURLSchemes"])
        {
            if ([self.scheme isEqualToString:scheme])
                return YES;
        }
    }
    
    return NO;
}

- (BOOL)isLocal {
    NSString *pattern = @"(.*)/Containers/Data/Application/(.*)";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:self.absoluteString options:NSMatchingReportProgress range:(NSRange) {0, self.absoluteString.length}];
    return matches && matches.count > 0;
}

- (BOOL)isWeb
{
    if (self.scheme)
    {
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http|https" options:NSRegularExpressionCaseInsensitive error:&error];
        NSArray *matches = [regex matchesInString:self.scheme options:NSMatchingReportProgress range:(NSRange) {0, self.scheme.length}];
        return matches && matches.count > 0;
    }
    return NO;
}

- (NSString *)URLStringByDeletingScheme
{
    return [[self absoluteString] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@://", [self scheme]] withString:@""];
}

- (NSString *)URLStringByDeletingQueryString
{
    return [NSString stringWithFormat:@"%@://%@%@", [self scheme], [self host], [self path]];
}

@end