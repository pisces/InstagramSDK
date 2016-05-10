//
//  NSString+w3action.h
//  w3action
//
//  Created by Steve Kim on 2013. 12. 30..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (w3action_NSString)
+ (NSString *)stringWithData:(NSData *)data;
- (NSDictionary *)urlParameters;
@end
