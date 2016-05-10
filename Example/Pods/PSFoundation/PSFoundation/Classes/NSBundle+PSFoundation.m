//
//  NSBundle+PSFoundation.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "NSBundle+PSFoundation.h"

@implementation NSBundle (PSFoundation_NSBundle)
- (NSDictionary *)dictionaryWithPlistName:(NSString*)plistName
{
    NSError *error = nil;
    NSPropertyListFormat format;
    NSString *plistPath = [self pathForResource:plistName ofType:@"plist"];
    plistPath = plistPath == nil ? [plistName stringByAppendingString:@".plist"] : plistPath;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    if (!plistXML)
        return nil;
    return [NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListImmutable format:&format error:&error];
}
@end