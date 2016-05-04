//
//  OAuth2Model.m
//  InstagramSDK
//
//  Created by pisces on 2016. 5. 3..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "OAuth2Model.h"
#import "InstagramAppCenter.h"

NSString *const kOAuthProeprtyAccessTokenKey = @"access_token";
NSString *const kOAuthProeprtyClientIdKey = @"client_id";
NSString *const kOAuthProeprtyClientSecretKey = @"client_secret";
NSString *const kOAuthProeprtyCodeKey = @"code";
NSString *const kOAuthProeprtyGrantTypeKey = @"grant_type";
NSString *const kOAuthProeprtyRedirectURIKey = @"redirect_uri";
NSString *const kOAuthProeprtyResponseTypeKey = @"response_type";
NSString *const kOAuthProeprtyScopeKey = @"scope";

@implementation OAuth2Model

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (OAuth2Model *)modelWithClientId:(NSString *)clientId clientSecret:(NSString *)clientSecret redirectURL:(NSString *)redirectURL scope:(InstagramOAuth2Scope)scope {
    OAuth2Model *model = [[OAuth2Model alloc] init];
    model.clientId = clientId;
    model.clientSecret = clientSecret;
    model.redirectURI = redirectURL;
    model.scope = scope;
    return model;
}

#pragma mark - Public getter/setter

- (NSString *)scopeString {
    return [self stringWithScope:_scope];
}

#pragma mark - Public methods

- (NSDictionary *)paramWithType:(InstagramParametersType)type {
    if (type == InstagramParametersTypeLogin)
        return @{kOAuthProeprtyClientIdKey: _clientId,
                 kOAuthProeprtyClientSecretKey: _clientSecret,
                 kOAuthProeprtyRedirectURIKey: _redirectURI,
                 kOAuthProeprtyResponseTypeKey: @"code",
                 kOAuthProeprtyScopeKey: self.scopeString};
    
    if (type == InstagramParametersTypeAccessToken)
        return @{kOAuthProeprtyClientIdKey: _clientId,
                 kOAuthProeprtyClientSecretKey: _clientSecret,
                 kOAuthProeprtyGrantTypeKey: @"authorization_code",
                 kOAuthProeprtyRedirectURIKey: _redirectURI,
                 kOAuthProeprtyCodeKey: [InstagramAppCenter defaultCenter].code};
    
    return nil;
}

- (NSString *)stringWithScope:(InstagramOAuth2Scope)scope {
    if (scope == InstagramOAuth2ScopeNone)
        return nil;
    
    const NSArray *typeStrings = @[@"basic",
                                   @"public_content",
                                   @"follower_list",
                                   @"comments",
                                   @"relationships",
                                   @"likes"];
    const NSMutableArray *strings = [NSMutableArray arrayWithCapacity:typeStrings.count];
    
#define kBitsUsedByIKLoginScope 6
    
    for (NSUInteger i=0; i<kBitsUsedByIKLoginScope; i++) {
        NSUInteger enumBitValueToCheck = 1 << i;
        if (scope & enumBitValueToCheck)
            [strings addObject:[typeStrings objectAtIndex:i]];
    }
    
    return [strings componentsJoinedByString:@"+"];
}

@end
