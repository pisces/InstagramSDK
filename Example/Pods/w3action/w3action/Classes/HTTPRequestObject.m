//
//  HTTPRequestObject.m
//  w3action
//
//  Created by Steve Kim on 2013. 12. 30..
//  Modified by Steve Kim on 15. 2. 5..
//  Modified by Steve Kim on 16. 2. 16..
//  Modified by Steve Kim on 16. 5. 9..
//  Copyright (c) 2013 ~ 2016~2016 Steve Kim. All rights reserved.
//

#import "HTTPRequestObject.h"

// ================================================================================================
//
//  Implementation: HTTPRequestObject
//
// ================================================================================================

@implementation HTTPRequestObject
{
@private
    CompletionBlock completionBlock;
    NSHTTPURLResponse *httpURLResponse;
    NSMutableData *mutableData;
    NSURLSession *session;
}

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (void)dealloc
{
    [self clear];
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

+ (HTTPRequestObject *)objectWithAction:(NSDictionary *)action param:(NSDictionary *)param body:(id)body headers:(NSDictionary *)headers success:(SuccessBlock)success error:(ErrorBlock)error
{
    HTTPRequestObject *instance = [HTTPRequestObject new];
    instance.action = action;
    instance.body = body;
    instance.param = param;
    instance.headers = headers;
    instance.successBlock = success;
    instance.errorBlock = error;
    return instance;
}

#pragma mark - Public getter/setter

- (void)setParam:(NSDictionary *)param
{
    if ([param isEqual:_param])
        return;
    
    _param = nil;
    _paramString = nil;
    
    if (!param)
        return;
    
    _param = param;
    _paramString = _param.urlEncodedString;
}

#pragma mark - Public methods

- (void)cancel
{
    [_sessionDataTask cancel];
    [session finishTasksAndInvalidate];
    
    completionBlock = NULL;
    httpURLResponse = nil;
    mutableData = nil;
    session = nil;
    _sessionDataTask = nil;
}

- (void)clear
{
    [self cancel];
    
    _action = nil;
    _body = nil;
    _headers = nil;
    _param = nil;
    _paramString = nil;
    _errorBlock = NULL;
    _successBlock = NULL;
}

- (NSString *)paramWithUTF8StringEncoding
{
    return [self.paramString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)sendAsynchronousRequest:(NSURLRequest *)request completion:(CompletionBlock)completion
{
    [self cancel];
    
    completionBlock = completion;
    
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    _sessionDataTask = [session dataTaskWithRequest:request];
    
    [_sessionDataTask resume];
}

- (NSData *)sendSynchronousRequest:(NSURLRequest *)request returningResponse:(NSHTTPURLResponse * __nullable * __nullable)response error:(NSError * __nullable * __nullable)error {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *result = nil;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable res, NSError * _Nullable err) {
        NSHTTPURLResponse *_response = (NSHTTPURLResponse *) res;
        *response = _response;
        
        if (err) {
            *error = err;
        } else {
            if (_response.statusCode >= 200 && _response.statusCode <= 304) {
                result = data;
            } else {
                *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{@"statusCode": @(httpURLResponse.statusCode)}];
            }
        }
        
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return result;
}

// ================================================================================================
//  Private
// ================================================================================================

#pragma mark - Private methods

- (void)errorStateWithResponse:(NSHTTPURLResponse *)response error:(NSError *)error
{
    if (completionBlock)
        completionBlock(response, nil, error);
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    [self errorStateWithResponse:nil error:error];
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

#pragma mark - NSURLSessionData delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    httpURLResponse = (NSHTTPURLResponse *) response;
    
    if (httpURLResponse.statusCode >= 200 && httpURLResponse.statusCode <= 304) {
        mutableData = [NSMutableData data];
        completionHandler(NSURLSessionResponseAllow);
    } else {
        completionHandler(NSURLSessionResponseCancel);
        [self errorStateWithResponse:httpURLResponse error:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:@{@"statusCode": @(httpURLResponse.statusCode)}]];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask {
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [mutableData appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * __nullable cachedResponse))completionHandler {
    completionHandler(proposedResponse);
}

#pragma mark - NSURLSessionTask delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        [self errorStateWithResponse:httpURLResponse error:error];
    } else if (completionBlock) {
        completionBlock(httpURLResponse, mutableData, nil);
    }
}

@end

// ================================================================================================
//
//  Implementation: MultipartFormDataObject
//
// ================================================================================================

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Public class methods

@implementation MultipartFormDataObject
+ (MultipartFormDataObject *)objectWithFilename:(NSString *)filename filetype:(NSString *)filetype data:(NSData *)data
{
    MultipartFormDataObject *object = [[MultipartFormDataObject alloc] init];
    object.filename = filename;
    object.filetype = filetype;
    object.data = data;
    return object;
}
@end
