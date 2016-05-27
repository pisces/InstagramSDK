//
//  AbstractModel.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

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
- (instancetype)format:(id)value forKey:(NSString *)key;
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
- (instancetype)unformat:(id)value forKey:(NSString *)key;
- (void)updateProperties:(NSDictionary *)dictionary;
@end

@protocol ModelClient <NSObject>
@property (nonatomic, strong) AbstractModel *model;
@end
