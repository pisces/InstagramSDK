//
//  NSData+w3action.m
//  w3action
//
//  Created by Steve Kim on 2013. 12. 30..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSData+w3action.h"

@implementation NSData (w3action_NSData)
- (NSDictionary *)dictionaryWithUTF8JSONString {
    @try {
        return [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingMutableContainers error:nil];
    }
    @catch (NSException *exception) {
        return nil;
    }
}
@end
