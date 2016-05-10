//
//  NSString+PSFoundation.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSString+PSFoundation.h"

@implementation NSString (PSFoundation_NSString)

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (NSString *)stringFromChar:(const char *)charText {
    return [NSString stringWithUTF8String:charText];
}

+ (const char *)charFromString:(NSString *)string {
    return [string cStringUsingEncoding:NSUTF8StringEncoding];
}

+ (const char *)wcharFromString:(NSString *)string {
    return [string cStringUsingEncoding:NSUTF16StringEncoding];
}

+ (NSString *)UUID {
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    return uuidString;
}

#pragma mark - Public getter/setter

- (NSString *)decode {
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)encode {
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)formatPhoneNumber {
    NSString *regexStr = @"(\\+82 (1[0-9]{1})|01([0-9]{1}))([0-9]{3,4})([0-9]{4})";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regexStr];
    if ([test evaluateWithObject:self])
    {
        return self.length >= 11 ? [self stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{4})(\\d{4})" withString:@"$1-$2-$3" options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])] : [self stringByReplacingOccurrencesOfString:@"(\\d{3})(\\d{3})(\\d{4})" withString:@"$1-$2-$3" options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])];
    }
    return nil;
}

- (BOOL)isEmpty {
    return ([self length] == 0);
}

- (NSString *)jpgDataURIWithContent; {
    return [NSString stringWithFormat: @"data:image/jpg;base64,%@", self];
}

- (NSString *)pngDataURIWithContent; {
    return [NSString stringWithFormat: @"data:image/png;base64,%@", self];
}

- (NSString *)trimmedString {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)urlEncode {
    CFStringRef str = CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef) self, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    NSString *result = [NSString stringWithString:(__bridge NSString *) str];
    CFRelease(str);
    return result;
}

#pragma mark - Public methods

- (NSComparisonResult)sortForIndex:(NSString *)comp {
    NSString* left = [NSString stringWithFormat:@"%@%@", [self localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" : !([self localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" : @"1", self];
    NSString* right = [NSString stringWithFormat:@"%@%@", [comp localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" : !([comp localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" : @"1", comp];
    
    unichar code = [comp characterAtIndex:0];
    
    if (code < 44032 && !((code >= 65 && code <= 90) || (code >= 97 && code <= 122)))
        right = @"2";
    
    return [left localizedCaseInsensitiveCompare:right];
}

@end
