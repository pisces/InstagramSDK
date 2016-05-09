//
//  HTTPActionManager.m
//  w3action
//
//  Created by Steve Kim on 2013. 12. 30..
//  Modified by Steve Kim on 15. 2. 5..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "HTTPActionManager.h"

NSString *const ContentTypeApplicationJSON = @"application/json";
NSString *const ContentTypeApplicationXML = @"application/xml";
NSString *const ContentTypeApplicationXWWWFormURLEncoded = @"application/x-www-form-urlencoded";
NSString *const ContentTypeMultipartFormData = @"multipart/form-data";
NSString *const DataTypeJSON = @"json";
NSString *const DataTypeXML = @"xml";
NSString *const DataTypeText = @"text";
NSString *const HTTPRequestMethodDelete = @"DELETE";
NSString *const HTTPRequestMethodGet = @"GET";
NSString *const HTTPRequestMethodPost = @"POST";
NSString *const HTTPResponseFieldConnection = @"Connection";
NSString *const HTTPResponseFieldContentLength = @"Content-Length";
NSString *const HTTPResponseFieldContentType = @"Content-Type";

NSString *const HTTPActionAsyncKey = @"async";
NSString *const HTTPActionContentTypeKey = @"contentType";
NSString *const HTTPActionDataTypeKey = @"dataType";
NSString *const HTTPActionMethodKey = @"method";
NSString *const HTTPActionTimeoutKey = @"timeout";
NSString *const HTTPActionURLKey = @"url";
NSString *const MultipartFormDataBoundary = @"0xKhTmLbOuNdArY";

// ================================================================================================
//
//  Implementation: NSURLObject
//
// ================================================================================================

@implementation NSURLObject
+ (NSURLObject *)objectWithRequest:(NSURLRequest *)request response:(NSHTTPURLResponse *)response
{
    NSURLObject *object = [[NSURLObject alloc] init];
    object.request = request;
    object.response = response;
    return object;
}
@end

// ================================================================================================
//
//  Implementation: HTTPActionManager
//
// ================================================================================================

@implementation HTTPActionManager
{
@private
    dispatch_queue_t networkQueue;
    NSMutableDictionary *actionPlist;
    NSMutableDictionary *actionPlistDictionary;
    NSMutableDictionary *urlObjectDic;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (void)dealloc
{
    networkQueue = NULL;
    actionPlist = nil;
    actionPlistDictionary = nil;
    urlObjectDic = nil;
    _headers = nil;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        networkQueue = dispatch_queue_create("org.apache.w3action.HTTPActionManager", NULL);
        actionPlist = [[NSMutableDictionary alloc] init];
        actionPlistDictionary = [[NSMutableDictionary alloc] init];
        urlObjectDic = [[NSMutableDictionary alloc] init];
        _useNetworkActivityIndicator = YES;
        _timeInterval = 10;
        _headers = [NSMutableDictionary dictionary];
    }
    
    return self;
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (HTTPActionManager *)sharedInstance
{
    static HTTPActionManager *instance;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

#pragma mark - Public methods

- (NSDictionary *)actionWith:(NSString *)actionId
{
    if ([self contains:actionId])
        return [actionPlist objectForKey:actionId];
    return nil;
}

- (void)addResourceWithBundle:(NSBundle *)bundle plistName:(NSString *)plistName
{
    NSString *key = [NSString stringWithFormat:@"%lu-%@", (unsigned long) bundle.hash, plistName];
    if ([actionPlistDictionary objectForKey:key])
        return;
    
    NSDictionary *rootDictionary = [bundle dictionaryWithPlistName:plistName];
    if (rootDictionary == nil)
    {
#if DEBUG
        NSLog(@"WARNING: %@.plist is missing.", plistName);
#endif
        return;
    }
    
    NSDictionary *actions = [rootDictionary objectForKey:@"Actions"];
    [actionPlist addEntriesFromDictionary:actions];
    [actionPlistDictionary setObject:actions forKey:key];
}

- (BOOL)contains:(NSString *)actionId
{
    if (actionPlist == nil)    return NO;
    return [actionPlist objectForKey:actionId] != nil;
}

- (HTTPRequestObject *)doAction:(NSString *)actionId param:(NSObject *)param body:(id)body headers:(NSDictionary *)headers success:(SuccessBlock)success error:(ErrorBlock)error
{
    if (![self contains:actionId])
    {
        error([NSError errorWithDomain:[NSString stringWithFormat:@"The name of actionId \"%@\" is not exist in plist.", actionId] code:99 userInfo:nil]);
        return nil;
    }
    
    NSDictionary *action = ((NSDictionary *) [actionPlist objectForKey:actionId]).copy;
    HTTPRequestObject *object = [HTTPRequestObject objectWithAction:action param:param body:body headers:headers success:success error:error];
    
    [self doRequest:object];
    
    return object;
}

- (HTTPRequestObject *)doActionWithRequestObject:(HTTPRequestObject *)object success:(SuccessBlock)success error:(ErrorBlock)error
{
    if (!object)
        return nil;
    
    object.successBlock = success;
    object.errorBlock = error;
    
    [self doRequest:object];
    
    return object;
}

- (void)removeResourceWithBundle:(NSBundle *)bundle plistName:(NSString *)plistName
{
    NSString *key = [NSString stringWithFormat:@"%lu-%@", (unsigned long) bundle.hash, plistName];
    if ([actionPlistDictionary objectForKey:key])
    {
        NSDictionary *actions = [actionPlistDictionary objectForKey:key];
        
        for (NSString *key in actions)
            [actionPlist removeObjectForKey:key];
        
        [actionPlistDictionary removeObjectForKey:key];
    }
}

- (NSURLObject *)URLObjectWithRequstObject:(HTTPRequestObject *)object
{
    return [urlObjectDic objectForKey:[NSNumber numberWithUnsignedLong:object.hash]];
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (void)doRequest:(HTTPRequestObject *)object
{
    dispatch_async(networkQueue, ^(void){
        NSURLRequest *request = [self requestWithObject:object];
        id asyncOption = [object.action objectForKey:HTTPActionAsyncKey];
        BOOL async = asyncOption ? [asyncOption boolValue] : _async;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.useNetworkActivityIndicator)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            if (async)
                [self sendAsynchronousRequest:request withObject:object];
            else
                [self sendSynchronousRequest:request withObject:object];
        });
    });
#if DEBUG
    NSLog(@"Request End -----------------------------------------");
#endif
}

- (NSError *)errorWithError:(NSError *)error data:(NSData *)data
{
    NSMutableDictionary *userInfo = error.userInfo ? [NSMutableDictionary dictionaryWithDictionary:error.userInfo] : [NSMutableDictionary dictionary];
    
    if (data)
        [userInfo setObject:data forKey:@"data"];
    
    return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

- (NSData *)multipartFormDataWithObject:(HTTPRequestObject *)object
{
    MultipartFormDataObject *mobject = (MultipartFormDataObject *) object.body;
    NSMutableData *body = [NSMutableData data];
    [object.param enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", MultipartFormDataBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", MultipartFormDataBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"Filedata\"; filename=\"%@\"\r\n", mobject.filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mobject.filetype] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:mobject.data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", MultipartFormDataBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    return body;
}

- (NSData *)postDataWithObject:(HTTPRequestObject *)object
{
    NSString *method = [object.action objectForKey:HTTPActionMethodKey];
    NSString *contentType = [object.action objectForKey:HTTPActionContentTypeKey];
    NSString *string = nil;
    
    if ([contentType isEqualToString:ContentTypeApplicationJSON]) {
        string = [((NSDictionary *) object.body) JSONString];
    } else if ([contentType isEqualToString:ContentTypeApplicationXML]) {
        string = [((NSDictionary *) object.body) urlString];
    } else {
        string = object.paramString != nil && ([method isEqualToString:HTTPRequestMethodPost] || [method isEqualToString:HTTPRequestMethodDelete]) ? object.paramString : nil;
    }
    
    return [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
}

- (NSString *)recursiveReplaceURLString:(NSString *)urlString object:(HTTPRequestObject *)object {
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:object.param];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{.*?\\}" options:0 error:nil];
    NSTextCheckingResult *matche = [regex firstMatchInString:urlString options:0 range:(NSRange) {0, urlString.length}];
    
    if (matche) {
        NSRegularExpression *propertyNameRegex = [NSRegularExpression regularExpressionWithPattern:@"\\{|\\}" options:0 error:nil];
        NSString *matchedString = [urlString substringWithRange:matche.range];
        NSString *propertyName = [propertyNameRegex stringByReplacingMatchesInString:matchedString options:0 range:(NSRange) {0, matchedString.length} withTemplate:@""];
        id value = [object.param objectForKey:propertyName];
        NSString *replaceString = [NSString stringWithFormat:@"%@", value];
        urlString = [regex stringByReplacingMatchesInString:urlString options:0 range:matche.range withTemplate:replaceString];
        
        [param removeObjectForKey:propertyName];
        
        object.param = param;
        urlString = [self recursiveReplaceURLString:urlString object:object];
    }
    
    return urlString;
}

- (NSURLRequest *)requestWithObject:(HTTPRequestObject *)object
{
    NSString *method = [object.action objectForKey:HTTPActionMethodKey];
    NSString *contentType = [object.action objectForKey:HTTPActionContentTypeKey];
    NSTimeInterval timeInterval = [object.action objectForKey:HTTPActionTimeoutKey] ? [[object.action objectForKey:HTTPActionTimeoutKey] doubleValue] : self.timeInterval;
    NSURL *url = [self URLWithObject:object];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:timeInterval];
    
    [request setHTTPMethod:method];
    
    for (NSString *key in self.headers)
        [request setValue:[self.headers objectForKey:key] forHTTPHeaderField:key];
    
    for (NSString *key in object.headers)
        [request setValue:[object.headers objectForKey:key] forHTTPHeaderField:key];
    
#if DEBUG
    NSLog(@"\nRequest Start -----------------------------------------\norgUrl -> %@,\nurl -> %@,\ncontentType -> %@,\n method -> %@,\n header -> %@,\n param -> %@", [object.action objectForKey:HTTPActionURLKey], url, contentType, method, request.allHTTPHeaderFields, object.param);
#endif
    if ([contentType isEqualToString:ContentTypeMultipartFormData])
    {
        NSData *body = [self multipartFormDataWithObject:object];
        [request setValue:[contentType stringByAppendingFormat:@"; boundary=%@", MultipartFormDataBoundary] forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:body];
    }
    else
    {
        NSData *body = [self postDataWithObject:object];
        NSString *bodyLength = [NSString stringWithFormat:@"%zd", body.length];
        [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        [request setValue:bodyLength forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:body];
    }
    return request;
}

- (id)resultWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data dataType:(NSString *)dataType
{
    if (!data)
        return nil;
    
    NSString *contentType = response.allHeaderFields[HTTPResponseFieldContentType];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^image/(.*)?$" options:0 error:nil];
    NSTextCheckingResult *matche = [regex firstMatchInString:contentType options:0 range:(NSRange) {0, contentType.length}];
    
    if (matche)
        return data;
    if ([dataType isEqualToString:DataTypeJSON])
        return [data dictionaryWithUTF8JSONString];
    if ([dataType isEqualToString:DataTypeXML])
        return [APDocument documentWithXMLString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
    if ([dataType isEqualToString:DataTypeText])
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return data;
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request withObject:(HTTPRequestObject *)object
{
    NSNumber *key = @(object.hash);
    
    [urlObjectDic setObject:[NSURLObject objectWithRequest:request response:nil] forKey:key];
    
    [object sendAsynchronousRequest:request completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (object.errorBlock)
                    object.errorBlock([self errorWithError:error data:data]);
                
                [urlObjectDic removeObjectForKey:key];
                [object clear];
                
                if (self.useNetworkActivityIndicator)
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            });
        } else {
            dispatch_async(networkQueue, ^{
                @autoreleasepool {
                    NSString *dataType = [object.action objectForKey:HTTPActionDataTypeKey];
                    id result = [self resultWithResponse:response data:data dataType:dataType];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (object.successBlock)
                            object.successBlock(result);
                        
                        [urlObjectDic removeObjectForKey:key];
                        [object clear];
                        
                        if (self.useNetworkActivityIndicator)
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    });
                }
            });
        }
    }];
}

- (void)sendSynchronousRequest:(NSURLRequest *)request withObject:(HTTPRequestObject *)object
{
    dispatch_async(networkQueue, ^{
        NSNumber *key = @(object.hash);
        NSError *error = nil;
        NSHTTPURLResponse *response = nil;
        NSData *data = [object sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *dataType = [object.action objectForKey:HTTPActionDataTypeKey];
        id result = !error && data ? [self resultWithResponse:response data:data dataType:dataType] : nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [urlObjectDic setObject:[NSURLObject objectWithRequest:request response:response] forKey:key];
            
            if (error) {
                object.errorBlock([self errorWithError:error data:data]);
            } else {
                object.successBlock(result);
            }
            
            [urlObjectDic removeObjectForKey:key];
            [object clear];
            
            if (self.useNetworkActivityIndicator)
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        });
    });
}

- (NSURL *)URLWithObject:(HTTPRequestObject *)object
{
    NSString *method = [object.action objectForKey:HTTPActionMethodKey];
    NSString *urlString = [self recursiveReplaceURLString:[object.action objectForKey:HTTPActionURLKey] object:object];
    
    if ([method isEqualToString:HTTPRequestMethodGet] && object.param && object.param.count > 0)
        urlString = [urlString stringByAppendingFormat:@"?%@", object.paramString];
    
    return [NSURL URLWithString:urlString];
}
@end

// ================================================================================================
//
//  Category: NSBundle (w3action_NSBundle)
//
// ================================================================================================

@implementation NSBundle (w3action_NSBundle)
- (NSDictionary *)dictionaryWithPlistName:(NSString*)plistName
{
    NSError *error = nil;
    NSPropertyListFormat format;
    NSString *plistPath = [self pathForResource:plistName ofType:@"plist"];
    plistPath = plistPath == nil ? [plistName stringByAppendingString:@".plist"] : plistPath;
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    if (!plistXML)
        return nil;
    return [NSPropertyListSerialization propertyListWithData:plistXML options:NSPropertyListImmutable format:&format error:&error];
}
@end
