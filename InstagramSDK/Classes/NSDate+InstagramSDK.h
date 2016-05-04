//
//  NSDate+InstagramSDK.h
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 14..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (org_apache_InstagramSDK_NSDate)
+ (NSDate *)dateFromInstagramDateString:(NSString *)dateString;
- (NSString *)instagramDateString;
@end
