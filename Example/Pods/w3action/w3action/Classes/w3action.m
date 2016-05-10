//
//  w3action.m
//  w3action
//
//  Created by Steve Kim on 2013. 12. 31..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "w3action.h"

@implementation w3action

+ (NSBundle *)bundle {
    return [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"w3action" ofType:@"bundle"]];
}

@end
