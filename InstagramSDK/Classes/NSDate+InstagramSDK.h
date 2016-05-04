//
//  NSDate+InstagramSDK.h
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 14..
//  Copyright (c) 2015년 orcllercorp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (org_apache_InstagramSDK_NSDate)
+ (NSDate *)dateFromInstagramDateString:(NSString *)dateString;
- (NSString *)instagramDateString;
@end
