//
//  NSURL+PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (PSFoundation_NSURL)
- (BOOL)isCurrentURLScheme;
- (BOOL)isLocal;
- (BOOL)isWeb;
- (NSString *)URLStringByDeletingScheme;
- (NSString *)URLStringByDeletingQueryString;
@end
