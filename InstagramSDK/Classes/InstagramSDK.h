//
//  InstagramSDK.h
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 2..
//  Copyright (c) 2015년 orcllercorp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InstagramApplicationCenter.h"

@interface InstagramSDK : NSObject
+ (NSBundle *)bundle;
+ (NSString *)localizedStringForKey:(NSString *)key table:(NSString *)table;
@end