//
//  InstagramSDK.h
//  InstagramSDK
//
//  Created by pisces on 2016. 5. 3..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramAppCenter.h"

@interface InstagramSDK : NSObject
+ (NSBundle *)bundle;
+ (NSString *)localizedStringForKey:(NSString *)key table:(NSString *)table;
@end