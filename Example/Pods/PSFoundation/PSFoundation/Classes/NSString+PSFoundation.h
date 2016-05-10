//
//  NSString+PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDate+PSFoundation.h"
#import "NSObject+PSFoundation.h"

@interface NSString (PSFoundation_NSString)
@property (nonatomic, readonly) NSString *decode;
@property (nonatomic, readonly) NSString *encode;
@property (nonatomic, readonly) NSString *formatPhoneNumber;
@property (nonatomic, readonly) NSString *jpgDataURIWithContent;
@property (nonatomic, readonly) NSString *pngDataURIWithContent;
@property (nonatomic, readonly) NSString *trimmedString;
@property (nonatomic, readonly) NSString *urlEncode;
+ (NSString *)stringFromChar:(const char *)charText;
+ (const char *)charFromString:(NSString *)string;
+ (const char /*wchar_t*/ *)wcharFromString:(NSString *)string;
+ (NSString *)UUID;
- (NSComparisonResult)sortForIndex:(NSString *)comp;
@end
