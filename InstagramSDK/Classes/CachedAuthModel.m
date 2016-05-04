//
//  CachedAuthModel.m
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 4..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "CachedAuthModel.h"

NSString *const kCachedAuthModelAccessTokenKey = @"access_token";
NSString *const kCachedAuthModelCodeKey = @"code";

@implementation CachedAuthModel

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (CachedAuthModel *)modelWithCode:(NSString *)code accessToken:(NSString *)accessToken {
    CachedAuthModel *model = [[CachedAuthModel alloc] init];
    model.code = code;
    model.accessToken = accessToken;
    return model;
}

+ (CachedAuthModel *)modelWithDictionary:(NSDictionary *)dictionary {
    CachedAuthModel *model = [[CachedAuthModel alloc] init];
    model.code = dictionary ? dictionary[kCachedAuthModelCodeKey] : nil;
    model.accessToken = dictionary ? dictionary[kCachedAuthModelAccessTokenKey] : nil;
    return model;
}

#pragma mark - Public getter/setter

- (NSDictionary *)dictionary {
    return _code && _accessToken ? @{kCachedAuthModelCodeKey: _code, kCachedAuthModelAccessTokenKey: _accessToken} : nil;
}

@end
