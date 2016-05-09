//
//  NSString+w3action.h
//  w3action
//
//  Created by Steve Kim on 2013. 12. 30..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

/*
 Copyright 2013~2015 Steve Kim
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

@interface NSString (w3action_NSString)
+ (NSString *)stringWithData:(NSData *)data;
- (NSDictionary *)urlParameters;
@end
