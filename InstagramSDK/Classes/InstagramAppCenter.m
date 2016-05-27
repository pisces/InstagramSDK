//
//  InstagramAppCenter.m
//  InstagramSDK
//
//  Created by pisces on 2016. 5. 3..
//  Copyright (c) 2016 pisces. All rights reserved.
//

#import "InstagramAppCenter.h"
#import "InstagramSDK.h"

NSTimeInterval const kExecutionDelayTimeInterval = 0.1;
NSString *const IGSDKErrorDomainAlreadyAuthorized = @"AlreadyAuthorizedErrorDomain";
NSString *const IGSDKErrorDomainInvalidClientId = @"InvalidClientIdErrorDomain";
NSString *const IGSDKErrorDomainInvalidClientSecret = @"InvalidClientSecretErrorDomain";
NSString *const IGSDKErrorDomainInvalidRedirectURI = @"InvalidRedirectURIErrorDomain";
NSString *const IGSDKErrorDomainNeedAuthorization = @"NeedAuthorizationErrorDomain";
NSString *const IGSDKErrorDomainUnknownAPIError = @"UnknownAPIErrorDomain";

NSString *const IGApiPathUsersSelf = @"/users/self";
NSString *const IGApiPathUsersUserId = @"/users/user-id";
NSString *const IGApiPathUsersSelfMediaRecent = @"/users/self/media/recent";
NSString *const IGApiPathUsersUserIdMediaRecent = @"/users/user-id/media/recent";
NSString *const IGApiPathUsersSelfMediaLiked = @"/users/self/media/liked";
NSString *const IGApiPathUsersSearch = @"/users/search";
NSString *const IGApiPathUsersSelfFollows = @"/users/self/follows";
NSString *const IGApiPathUsersSelfFollowedBy = @"/users/self/followed-by";
NSString *const IGApiPathUsersSelfRequestedBy = @"/users/self/requested-by";
NSString *const IGApiPathUsersUserIdRelationship = @"/users/user-id/relationship";
NSString *const IGApiPathUsersUserIdRelationshipPost = @"/users/user-id/relationship/post";
NSString *const IGApiPathMediaMediaId = @"/media/media-id";
NSString *const IGApiPathMediaShortcodeShortcode = @"/media/shortcode/shortcode";
NSString *const IGApiPathMediaSearch = @"/media/search";
NSString *const IGApiPathMediaMediaIdComments = @"/media/media-id/comments";
NSString *const IGApiPathMediaMediaIdCommentsPost = @"/media/media-id/comments/post";
NSString *const IGApiPathMediaMediaIdCommentsCommentId = @"/media/media-id/comments/comment-id";
NSString *const IGApiPathMediaMediaIdLikes = @"/media/media-id/likes";
NSString *const IGApiPathMediaMediaIdLikesPost = @"/media/media-id/likes/post";
NSString *const IGApiPathMediaMediaIdLikesDel = @"/media/media-id/likes/del";
NSString *const IGApiPathTagsTagname = @"/tags/tag-name";
NSString *const IGApiPathTagsTagnameMediaRecent = @"/tags/tag-name/media/recent";
NSString *const IGApiPathTagsSearch = @"/tags/search";
NSString *const IGApiPathLocationsLocationId = @"/locations/location-id";
NSString *const IGApiPathLocationsLocationIdMediaRecent = @"/locations/location-id/media/recent";
NSString *const IGApiPathLocationsSearch = @"/locations/search";
NSString *const IGApiPathSubscriptions = @"/subscriptions";
NSString *const IGApiPathSubscriptionsDel = @"/subscriptions/del";

NSString *const kCachedAuthDictionaryKey = @"kCachedAuthDictionaryKey";
NSString *const kInstagramMaxId = @"max_id";
NSString *const kInstagramListCount = @"count";

@interface InstagramAppCenter ()
@property (nonatomic, strong) CachedAuthModel *cachedAuthModel;
@end

@implementation InstagramAppCenter
{
@private
    NSMutableArray *apiObjectQueue;
    NSTimer *executionDelayTimer;
    IGRequestCompletion completionBlock;
    InstagramLoginViewController *loginViewController;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [executionDelayTimer invalidate];
    
    executionDelayTimer = nil;
}

- (id)init {
    self = [super init];
    
    if (self) {
        apiObjectQueue = [NSMutableArray array];
        
        id cachedAuthDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kCachedAuthDictionaryKey];
        if (cachedAuthDictionary) {
            _cachedAuthModel = [CachedAuthModel modelWithDictionary:cachedAuthDictionary];
        }
        
        _accessToken = _cachedAuthModel.accessToken;
        _code = _cachedAuthModel.code;
        
        [[HTTPActionManager sharedInstance] addResourceWithBundle:[InstagramSDK bundle] plistName:@"action"];
    }
    
    return self;
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (InstagramAppCenter *)defaultCenter {
    static InstagramAppCenter *instance;
    static dispatch_once_t precate;
    
    dispatch_once(&precate, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

#pragma mark - Public getter/setter

- (NSArray<NSString *> *)apiPaths {
    return @[IGApiPathUsersSelf,
             IGApiPathUsersUserId,
             IGApiPathUsersSelfMediaRecent,
             IGApiPathUsersUserIdMediaRecent,
             IGApiPathUsersSelfMediaLiked,
             IGApiPathUsersSearch,
             IGApiPathUsersSelfFollows,
             IGApiPathUsersSelfFollowedBy,
             IGApiPathUsersSelfRequestedBy,
             IGApiPathUsersUserIdRelationship,
             IGApiPathUsersUserIdRelationshipPost,
             IGApiPathMediaMediaId,
             IGApiPathMediaShortcodeShortcode,
             IGApiPathMediaSearch,
             IGApiPathMediaMediaIdComments,
             IGApiPathMediaMediaIdCommentsPost,
             IGApiPathMediaMediaIdCommentsCommentId,
             IGApiPathMediaMediaIdLikes,
             IGApiPathMediaMediaIdLikesPost,
             IGApiPathMediaMediaIdLikesDel,
             IGApiPathTagsTagname,
             IGApiPathTagsTagnameMediaRecent,
             IGApiPathTagsSearch,
             IGApiPathLocationsLocationId,
             IGApiPathLocationsLocationIdMediaRecent,
             IGApiPathLocationsSearch,
             IGApiPathSubscriptions,
             IGApiPathSubscriptionsDel];
}

- (BOOL)hasSession {
    return _accessToken != nil;
}

#pragma mark - Public methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([url.absoluteString hasPrefix:_model.redirectURI]) {
        _code = url.query.urlParameters[@"code"];
        
        [loginViewController dismiss];
        
        if (_code) {
            [self accessTokenWithCompletion:completionBlock dequeue:YES];
        }
        
        return YES;
    }
    
    return NO;
}

- (IGApiObject *)apiCallWithPath:(NSString *)path param:(NSDictionary *)param completion:(IGRequestCompletion)completion {
    IGApiObject *object = [IGApiObject objectWithPath:path param:param headers:nil completion:completion];
    [self enqueueWithObject:object];
    [self dequeue];
    return object;
}

- (void)loginWithCompletion:(IGRequestCompletion)completion {
    if ([self invalidateModel:completion])
        return;
    
    if (_code) {
        [self refreshWithCompletion:completion];
    } else if (!loginViewController) {
        completionBlock = completion;
        
        loginViewController = [[InstagramLoginViewController alloc] initWithModel:_model];
        loginViewController.delegate = self;
        loginViewController.model = _model;
        
        [loginViewController present];
    }
}

- (void)logout {
    self.cachedAuthModel = nil;
    completionBlock = nil;
    loginViewController = nil;
    _accessToken = nil;
    _code = nil;
}

- (BOOL)matchedURL:(NSURL *)URL {
    return [URL.absoluteString hasPrefix:_model.redirectURI];
}

- (void)refreshWithCompletion:(IGRequestCompletion)completion {
    if (![self invalidateCode:completion])
        [self accessTokenWithCompletion:completion dequeue:NO];
}

- (void)setUpWithClientId:(NSString *)clientId
             clientSecret:(NSString *)clientSecret
              redirectURL:(NSString *)redirectURL {
    _model = [OAuth2Model modelWithClientId:clientId
                               clientSecret:clientSecret
                                redirectURL:redirectURL
                                      scope:InstagramOAuth2ScopeBasic];
}

// ================================================================================================
//  Protocol Implementation
// ================================================================================================

#pragma mark - InstagramLoginViewController delegate

- (void)didDismissViewController {
    [executionDelayTimer invalidate];
    
    completionBlock = nil;
    executionDelayTimer = nil;
    loginViewController = nil;
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private getter/setter

- (void)setCachedAuthModel:(CachedAuthModel *)cachedAuthModel {
    if ([cachedAuthModel isEqual:_cachedAuthModel])
        return;
    
    _cachedAuthModel = cachedAuthModel;
    
    if (cachedAuthModel) {
        [[NSUserDefaults standardUserDefaults] setObject:cachedAuthModel.dictionary forKey:kCachedAuthDictionaryKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCachedAuthDictionaryKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private methods

- (void)accessTokenWithCompletion:(IGRequestCompletion)completion dequeue:(BOOL)dequeue {
    if ([self invalidateCode:completion])
        return;
    
    [[HTTPActionManager sharedInstance] doAction:@"token" param:[_model paramWithType:InstagramParametersTypeAccessToken] body:nil headers:nil success:^(id result) {
        if (result) {
            _accessToken = result[kOAuthProeprtyAccessTokenKey];
            self.cachedAuthModel = [CachedAuthModel modelWithCode:_code accessToken:_accessToken];
            
            if (completion)
                completion(result, nil);
            
            if (dequeue)
                [self dequeue];
        }
    } error:^(NSError *err) {
        if (completion)
            completion(nil, err);
    }];
}

- (void)completionHandlerWithSource:(NSDictionary *)source class:(Class)class completion:(IGRequestCompletion)completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AbstractJSONModel *model = [[class alloc] initWithObject:source];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(model, nil);
        });
    });
}

- (void)enqueueWithObject:(IGApiObject *)object {
    if (![apiObjectQueue containsObject:object]) {
        [apiObjectQueue addObject:object];
    }
}

- (void)dequeue {
    if (apiObjectQueue.count < 1 || executionDelayTimer)
        return;
    
    IGApiObject *object = apiObjectQueue.firstObject;
    
    typedef void (^ExecuteBlock)(void);
    typedef void (^ErrorBlock)(NSError *error);
    ExecuteBlock executeBlock;
    ErrorBlock errorBlock;
    
    errorBlock = ^void(NSError *error) {
        if (object.completion)
            object.completion(nil, error);
        
        [object clear];
    };
    
    executeBlock = ^(void) {
        [apiObjectQueue removeObjectAtIndex:0];
        
        NSMutableDictionary *param = object.param ? [NSMutableDictionary dictionaryWithDictionary:object.param] : [NSMutableDictionary dictionary];
        NSMutableDictionary *queryParam;
        
        if ([self needsQueryParamWithPath:object.path]) {
            queryParam = [NSMutableDictionary dictionaryWithDictionary:object.param];
            
            [queryParam setObject:_model.clientId forKey:kOAuthProeprtyClientIdKey];
            [queryParam setObject:_model.clientSecret forKey:kOAuthProeprtyClientSecretKey];
            [param removeAllObjects];
        } else {
           queryParam = [NSMutableDictionary dictionary];
        }
        
        [queryParam setObject:_accessToken forKey:kOAuthProeprtyAccessTokenKey];
        
        NSString *scopeString = nil;
        
        if (!param[kOAuthProeprtyScopeKey] && (scopeString = [self scopeStringWithPath:object.path])) {
            [param setObject:scopeString forKey:kOAuthProeprtyScopeKey];
        }
        
        [[HTTPActionManager sharedInstance] doAction:object.path queryParam:queryParam param:param body:nil headers:object.headers success:^(NSDictionary *result){
            [self processWithResult:result completion:object.completion];
            [object clear];
        } error:^(NSError *error) {
            if (error.code == NSURLErrorUnknown) {
                [self refreshWithCompletion:^(id result, NSError *err) {
                    if (err) {
                        errorBlock(err);
                    } else {
                        executeBlock();
                    }
                }];
            } else {
                errorBlock(error);
            }
        }];
        
        executionDelayTimer = [NSTimer scheduledTimerWithTimeInterval:kExecutionDelayTimeInterval target:self selector:@selector(timerComplete) userInfo:nil repeats:NO];
    };
    
    if (self.hasSession) {
        executeBlock();
    } else {
        [self loginWithCompletion:^(id result, NSError *error) {
            if (error) {
                errorBlock(error);
            } else {
                executeBlock();
            }
        }];
    }
}

- (BOOL)invalidateCode:(IGRequestCompletion)completion {
    if (_code)
        return NO;
    
    if (completion) {
        completion(nil, [NSError errorWithDomain:IGSDKErrorDomainNeedAuthorization code:NeedAuthorizationError userInfo:nil]);
    }
    
    return YES;
}

- (BOOL)invalidateModel:(IGRequestCompletion)completion {
    if (!_model.clientId) {
        completion(nil, [NSError errorWithDomain:IGSDKErrorDomainInvalidClientId code:InvalidClientIdError userInfo:nil]);
        return YES;
    }
    
    if (!_model.clientSecret) {
        completion(nil, [NSError errorWithDomain:IGSDKErrorDomainInvalidClientSecret code:InvalidClientSecretError userInfo:nil]);
        return YES;
        
    }
    
    if (!_model.redirectURI) {
        completion(nil, [NSError errorWithDomain:IGSDKErrorDomainInvalidRedirectURI code:InvalidRedirectURIError userInfo:nil]);
        return YES;
    }
    
    return NO;
}

- (BOOL)needsQueryParamWithPath:(NSString *)path {
    return [path isEqualToString:IGApiPathSubscriptions] || [path isEqualToString:IGApiPathSubscriptionsDel];
}

- (void)processWithResult:(id)result completion:(IGRequestCompletion)completion {
    if (!completion)
        return;
    
    if (result) {
        completion(result, nil);
    } else {
        completion(nil, [NSError errorWithDomain:IGSDKErrorDomainUnknownAPIError code:UnknownAPIError userInfo:nil]);
    }
}

- (NSString *)scopeStringWithPath:(NSString *)path {
    InstagramOAuth2Scope scope = InstagramOAuth2ScopeNone;
    
    if ([path isEqualToString:IGApiPathUsersSelfMediaRecent] ||
        [path isEqualToString:IGApiPathUsersSelf]) {
        scope = InstagramOAuth2ScopeBasic;
    } else if ([path isEqualToString:IGApiPathUsersUserId] ||
               [path isEqualToString:IGApiPathUsersUserIdMediaRecent] ||
               [path isEqualToString:IGApiPathUsersSelfMediaLiked] ||
               [path isEqualToString:IGApiPathUsersSearch] ||
               [path isEqualToString:IGApiPathMediaSearch] ||
               [path isEqualToString:IGApiPathTagsTagname] ||
               [path isEqualToString:IGApiPathTagsTagnameMediaRecent] ||
               [path isEqualToString:IGApiPathTagsSearch] ||
               [path isEqualToString:IGApiPathLocationsLocationId] ||
               [path isEqualToString:IGApiPathLocationsLocationIdMediaRecent] ||
               [path isEqualToString:IGApiPathLocationsSearch]) {
        scope = InstagramOAuth2ScopePublicContent;
    } else if ([path isEqualToString:IGApiPathUsersSelfFollows] ||
               [path isEqualToString:IGApiPathUsersSelfFollowedBy] ||
               [path isEqualToString:IGApiPathUsersSelfRequestedBy] ||
               [path isEqualToString:IGApiPathUsersUserIdRelationship]) {
        scope = InstagramOAuth2ScopeFollowerList;
    } else if ([path isEqualToString:IGApiPathUsersUserIdRelationshipPost]) {
        scope = InstagramOAuth2ScopeRelationships;
    } else if ([path isEqualToString:IGApiPathMediaMediaId] ||
               [path isEqualToString:IGApiPathMediaMediaIdComments] ||
               [path isEqualToString:IGApiPathMediaMediaIdLikes] ||
               [path isEqualToString:IGApiPathMediaShortcodeShortcode]) {
        scope = InstagramOAuth2ScopeBasic | InstagramOAuth2ScopePublicContent;
    } else if ([path isEqualToString:IGApiPathMediaMediaIdCommentsPost] ||
               [path isEqualToString:IGApiPathMediaMediaIdCommentsCommentId]) {
        scope = InstagramOAuth2ScopeComments;
    } else if ([path isEqualToString:IGApiPathMediaMediaIdLikesDel] ||
               [path isEqualToString:IGApiPathMediaMediaIdLikesPost]) {
        scope = InstagramOAuth2ScopeLikes;
    }
    
    return [_model stringWithScope:scope];
}

#pragma mark - NSTimer selector

- (void)timerComplete {
    [executionDelayTimer invalidate];
    executionDelayTimer = nil;
    [self dequeue];
}

@end

@implementation IGApiObject
+ (IGApiObject *)objectWithPath:(NSString *)path param:(NSDictionary *)param headers:(NSDictionary *)headers completion:(IGRequestCompletion)completion {
    IGApiObject *object = [[IGApiObject alloc] init];
    object.path = path;
    object.param = param;
    object.headers = headers;
    object.completion = completion;
    return object;
}

- (void)dealloc {
    [self clear];
}

- (void)clear {
    _path = nil;
    _param = nil;
    _headers = nil;
    _completion = NULL;
}

@end