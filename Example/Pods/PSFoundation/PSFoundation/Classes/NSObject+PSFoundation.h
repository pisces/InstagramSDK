//
//  PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 Steve Kim. All rights reserved.
//

/*
 Copyright 2015 Steve Kim
 
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

@interface NSObject (org_apache_PSFoundation_NSObject)
@property (nonatomic, readonly) BOOL dataLoading;
@property (nonatomic, readonly, getter=isFirstLoading) BOOL firstLoading;
@property (nonatomic, readonly) BOOL hasValue;
@property (nonatomic, readonly) BOOL isEmpty;
+ (id)value:(id)value;
- (void)endDataLoading;
- (BOOL)invalidDataLoading;
@end
