//
//  NSDate+PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PSFoundation_NSDate)
- (NSString *)relativeTimeSpanString;
@end

@interface NSDateFormatter (PSFoundation_NSDateFormatter)
+ (NSDateFormatter *)localizedFormatter;
@end