//
//  NSDate+PSFoundation.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSDate+PSFoundation.h"
#import "PSFoundation.h"

@implementation NSDate (PSFoundation_NSDate)

// ================================================================================================
//  Public
// ================================================================================================

- (NSString *)relativeTimeSpanString
{
    NSCalendarUnit flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSCalendar *currCalendar = [NSCalendar currentCalendar];
    NSDate *nowDate = [NSDate date];
    NSDateComponents *this = [currCalendar components:flags fromDate:self];
    NSDateComponents *now = [currCalendar components:flags fromDate:nowDate];
    NSDateComponents *compare = [currCalendar components:flags fromDate:self toDate:nowDate options:0];
    NSString *monthKey = [NSString stringWithFormat:@"%zdmonth", this.month];
    
    if (this.year == now.year) {
        if (compare.month > 0)
            return [NSString stringWithFormat:@"%@ %zd%@", [PSFoundation localizedStringWithKey:monthKey], this.day, [PSFoundation localizedStringWithKey:@"days"]];
        
        if (compare.day > 0) {
            NSUInteger day = ABS(compare.day);
            if (day == 1)
                return [PSFoundation localizedStringWithKey:@"yesterday"];
            if (day == 2)
                return [PSFoundation localizedStringWithKey:@"before_yesterday"];
            return [NSString stringWithFormat:@"%tu %@", day, [PSFoundation localizedStringWithKey:day > 1 ? @"days_ago" : @"day_ago"]];
        }
        
        if (compare.hour > 0)
            return [NSString stringWithFormat:@"%tu %@", ABS(compare.hour), [PSFoundation localizedStringWithKey:compare.hour > 1 ? @"hours_ago" : @"hour_ago"]];
        
        if (compare.minute > 0)
            return [NSString stringWithFormat:@"%tu %@", ABS(compare.minute), [PSFoundation localizedStringWithKey:compare.minute > 1 ? @"minutes_ago" : @"minute_ago"]];
        
        NSUInteger second = ABS(compare.second);
        return (second <= 10) ? [PSFoundation localizedStringWithKey:@"just_now"] : [NSString stringWithFormat:@"%tu %@", second, [PSFoundation localizedStringWithKey:@"seconds_ago"]];
    }
    
    NSDateFormatter *formatter = [NSDateFormatter localizedFormatter];
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"ko" options:0 error:NULL];
    NSArray *matches = [expression matchesInString:formatter.locale.localeIdentifier options:0 range:NSMakeRange(0, formatter.locale.localeIdentifier.length)];
    
    if (matches.count > 0)
        return [NSString stringWithFormat:@"%zd%@ %@ %zd%@", this.year, [PSFoundation localizedStringWithKey:@"years"], [PSFoundation localizedStringWithKey:monthKey], this.day, [PSFoundation localizedStringWithKey:@"days"]];
    
    return [NSString stringWithFormat:@"%@ %zd%@, %zd", [PSFoundation localizedStringWithKey:monthKey], this.day, [PSFoundation localizedStringWithKey:@"days"], this.year];
}

@end

@implementation NSDateFormatter (org_apache_PSUIKit_NSDateFormatter)
+ (NSDateFormatter *)localizedFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale currentLocale];
    return formatter;
}
@end
