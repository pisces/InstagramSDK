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

#import <Foundation/Foundation.h>
#import "NSDate+PSFoundation.h"
#import "NSObject+PSFoundation.h"

@interface NSString (org_apache_PSFoundation_NSString)
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
