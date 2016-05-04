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

#import "NSDate+PSFoundation.h"
#import "PSFoundation.h"

@implementation NSDate (org_apache_PSFoundation_NSDate)

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
