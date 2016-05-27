//
//  InstagramAppCenter.h
//  InstagramSDK
//
//  Created by pisces on 2016. 5. 3..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import <w3action/w3action.h>
#import "InstagramLoginViewController.h"
#import "CachedAuthModel.h"
#import "InstagramSDKMacros.h"
#import "OAuth2Model.h"

typedef NS_OPTIONS(NSInteger, InstagramErrorCode) {
    AlreadyAuthorizedError = 10000,
    InvalidClientIdError = 10001,
    InvalidClientSecretError = 10002,
    InvalidRedirectURIError = 10003,
    NeedAuthorizationError = 10004,
    UnknownAPIError = 10100
};

IGSDK_EXTERN NSString *const IGSDKErrorDomainAlreadyAuthorized;
IGSDK_EXTERN NSString *const IGSDKErrorDomainInvalidClientId;
IGSDK_EXTERN NSString *const IGSDKErrorDomainInvalidClientSecret;
IGSDK_EXTERN NSString *const IGSDKErrorDomainInvalidRedirectURI;
IGSDK_EXTERN NSString *const IGSDKErrorDomainNeedAuthorization;
IGSDK_EXTERN NSString *const IGSDKErrorDomainUnknownAPIError;

IGSDK_EXTERN NSString *const IGApiPathUsersSelf;
IGSDK_EXTERN NSString *const IGApiPathUsersUserId;
IGSDK_EXTERN NSString *const IGApiPathUsersSelfMediaRecent;
IGSDK_EXTERN NSString *const IGApiPathUsersUserIdMediaRecent;
IGSDK_EXTERN NSString *const IGApiPathUsersSelfMediaLiked;
IGSDK_EXTERN NSString *const IGApiPathUsersSearch;
IGSDK_EXTERN NSString *const IGApiPathUsersSelfFollows;
IGSDK_EXTERN NSString *const IGApiPathUsersSelfFollowedBy;
IGSDK_EXTERN NSString *const IGApiPathUsersSelfRequestedBy;
IGSDK_EXTERN NSString *const IGApiPathUsersUserIdRelationship;
IGSDK_EXTERN NSString *const IGApiPathUsersUserIdRelationshipPost;
IGSDK_EXTERN NSString *const IGApiPathMediaMediaId;
IGSDK_EXTERN NSString *const IGApiPathMediaShortcodeShortcode;
IGSDK_EXTERN NSString *const IGApiPathMediaSearch;
IGSDK_EXTERN NSString *const IGApiPathMediaMediaIdComments;
IGSDK_EXTERN NSString *const IGApiPathMediaMediaIdCommentsPost;
IGSDK_EXTERN NSString *const IGApiPathMediaMediaIdCommentsCommentId;
IGSDK_EXTERN NSString *const IGApiPathMediaMediaIdLikes;
IGSDK_EXTERN NSString *const IGApiPathMediaMediaIdLikesPost;
IGSDK_EXTERN NSString *const IGApiPathMediaMediaIdLikesDel;
IGSDK_EXTERN NSString *const IGApiPathTagsTagname;
IGSDK_EXTERN NSString *const IGApiPathTagsTagnameMediaRecent;
IGSDK_EXTERN NSString *const IGApiPathTagsSearch;
IGSDK_EXTERN NSString *const IGApiPathLocationsLocationId;
IGSDK_EXTERN NSString *const IGApiPathLocationsLocationIdMediaRecent;
IGSDK_EXTERN NSString *const IGApiPathLocationsSearch;
IGSDK_EXTERN NSString *const IGApiPathSubscriptions;
IGSDK_EXTERN NSString *const IGApiPathSubscriptionsDel;

typedef void (^IGRequestCompletion)(id result, NSError *error);

@interface IGApiObject : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSDictionary *param;
@property (nonatomic, copy) IGRequestCompletion completion;
+ (IGApiObject *)objectWithPath:(NSString *)path param:(NSDictionary *)param headers:(NSDictionary *)headers completion:(IGRequestCompletion)completion;
- (void)clear;
@end

@interface InstagramAppCenter : NSObject <InstagramLoginViewControllerDelegate>
@property (nonatomic, readonly) BOOL hasSession;
@property (nonatomic, readonly) NSString *accessToken;
@property (nonatomic, readonly) NSString *code;
@property (nonatomic, readonly) NSArray<NSString *> *apiPaths;
@property (nonatomic, readonly) OAuth2Model *model;
+ (InstagramAppCenter *)defaultCenter;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation NS_AVAILABLE_IOS(4_2);
- (IGApiObject *)apiCallWithPath:(NSString *)path param:(NSDictionary *)param completion:(IGRequestCompletion)completion;
- (void)loginWithCompletion:(IGRequestCompletion)completion;
- (void)logout;
- (BOOL)matchedURL:(NSURL *)URL;
- (void)refreshWithCompletion:(IGRequestCompletion)completion;
- (void)setUpWithClientId:(NSString *)clientId
             clientSecret:(NSString *)clientSecret
              redirectURL:(NSString *)redirectURL;
@end