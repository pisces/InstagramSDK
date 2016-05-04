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

#import "BaseObject.h"
#import <objc/runtime.h>


extern NSString *const kModelDidChangePropertiesNotification;
extern NSString *const kModelDidSynchronizeNotification;

@interface AbstractModel : BaseObject
@property (nonatomic, readonly) NSDictionary *dictionary;
@property (nonatomic, readonly) NSDictionary *sourceObject;
- (id)childWithArray:(NSArray *)array classType:(Class)classType;
- (id)childWithArray:(NSArray *)array classType:(Class)classType map:(void (^)(AbstractModel *model))map;
- (id)childWithKey:(NSString *)key classType:(Class)classType;
- (id)childWithKey:(NSString *)key classType:(Class)classType map:(void (^)(AbstractModel *model))map;
- (id)body;
- (NSDictionary *)dictionaryWithExcludes:(NSArray *)excludes;
- (void)didChangeProperties;
- (void)equals:(AbstractModel *)other block:(void(^)(BOOL equal))block;
- (id)format:(id)value forKey:(NSString *)key;
- (instancetype)initWithObject:(id)object;
- (BOOL)isEqualToModel:(AbstractModel *)other;
- (void)setProperties:(id)object;
- (void)synchronize:(AbstractModel *)other;
- (void)synchronize:(AbstractModel *)other completion:(void(^)(void))completion;
- (void)synchronize:(AbstractModel *)other completion:(void(^)(void))completion postEnabled:(BOOL)postEnabled;
- (void)synchronize:(AbstractModel *)other postEnabled:(BOOL)postEnabled;
- (void)synchronizeSource;
- (NSString *)toString;
- (NSString *)toSourceString;
- (id)unformat:(id)value forKey:(NSString *)key;
- (void)updateProperties:(NSDictionary *)dictionary;
@end

@protocol ModelClient <NSObject>
@property (nonatomic, strong) AbstractModel *model;
@end
