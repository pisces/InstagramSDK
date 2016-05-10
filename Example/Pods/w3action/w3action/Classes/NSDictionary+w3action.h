//
//  NSDictionary+w3action.h
//  w3action
//
//  Created by pisces on 2015. 8. 11..
//  Copyright (c) 2015년 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (w3action_NSDictionary)
- (NSString * _Nullable)JSONString;
- (NSString * _Nullable)urlEncodedString;
- (NSString * _Nullable)urlString;
@end
