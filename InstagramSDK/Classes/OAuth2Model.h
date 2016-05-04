//
//  OAuth2Model.h
//  InstagramSDK
//
//  Created by pisces on 2016. 5. 3..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kOAuthProeprtyAccessTokenKey;
extern NSString *const kOAuthProeprtyClientIdKey;
extern NSString *const kOAuthProeprtyClientSecretKey;
extern NSString *const kOAuthProeprtyCodeKey;
extern NSString *const kOAuthProeprtyGrantTypeKey;
extern NSString *const kOAuthProeprtyRedirectURIKey;
extern NSString *const kOAuthProeprtyResponseTypeKey;
extern NSString *const kOAuthProeprtyScopeKey;

typedef NS_OPTIONS(NSUInteger, InstagramOAuth2Scope) {
    InstagramOAuth2ScopeNone = 0,
    InstagramOAuth2ScopeBasic = 1,
    InstagramOAuth2ScopePublicContent = 1<<1,
    InstagramOAuth2ScopeFollowerList = 1<<2,
    InstagramOAuth2ScopeComments = 1<<3,
    InstagramOAuth2ScopeRelationships = 1<<4,
    InstagramOAuth2ScopeLikes = 1<<5
};

typedef NS_OPTIONS(NSUInteger, InstagramParametersType) {
    InstagramParametersTypeLogin = 1,
    InstagramParametersTypeAccessToken = 2
};

@interface OAuth2Model : NSObject
@property (nonatomic) InstagramOAuth2Scope scope;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURI;
@property (nonatomic, readonly) NSString *scopeString;
+ (OAuth2Model *)modelWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectURL:(NSString *)redirectURL scope:(InstagramOAuth2Scope)scope;
- (NSDictionary *)paramWithType:(InstagramParametersType)type;
- (NSString *)stringWithScope:(InstagramOAuth2Scope)scope;
@end