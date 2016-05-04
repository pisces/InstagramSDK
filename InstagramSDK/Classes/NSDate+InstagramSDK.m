//
//  NSDate+InstagramSDK.m
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 14..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "NSDate+InstagramSDK.h"

@implementation NSDate (org_apache_InstagramSDK_NSDate)

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (NSDate *)dateFromInstagramDateString:(NSString *)dateString {
    NSTimeInterval interval = [dateString doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:interval];
}

#pragma mark - Public methods

- (NSString *)instagramDateString {
    return [NSString stringWithFormat:@"%zd", self.timeIntervalSince1970];
}

@end
