//
//  CachedAuthModel.h
//  InstagramSDK
//
//  Created by pisces on 2015. 5. 4..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import <PSFoundation/PSFoundation.h>

@interface CachedAuthModel : BaseObject
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, readonly) NSDictionary *dictionary;
+ (CachedAuthModel *)modelWithCode:(NSString *)code accessToken:(NSString *)accessToken;
+ (CachedAuthModel *)modelWithDictionary:(NSDictionary *)dictionary;
@end
