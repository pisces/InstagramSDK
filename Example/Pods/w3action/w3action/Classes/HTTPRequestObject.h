//
//  HTTPRequestObject.h
//  w3action
//
//  Created by Steve Kim on 13. 12. 30..
//  Modified by Steve Kim on 15. 2. 5..
//  Modified by Steve Kim on 16. 2. 16..
//  Copyright (c) 2013 ~ 2016~2016 Steve Kim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+w3action.h"

typedef void (^SuccessBlock)(id _Nullable result);
typedef void (^ErrorBlock)(NSError * _Nullable error);
typedef void (^CompletionBlock)(NSHTTPURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable error);

@interface HTTPRequestObject : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate>
@property(nonatomic, strong) NSDictionary * _Nonnull action;
@property(nonatomic, strong) id _Nullable body;
@property(nonatomic, strong) NSDictionary * _Nullable headers;
@property(nonatomic, strong) NSDictionary * _Nullable param;
@property(nonatomic, readonly) NSString * _Nullable paramString;
@property(nonatomic, readonly) NSURLSessionDataTask * _Nonnull sessionDataTask;
@property(nonatomic, copy) SuccessBlock _Nullable successBlock;
@property(nonatomic, copy) ErrorBlock _Nullable errorBlock;
+ (HTTPRequestObject * _Nullable)objectWithAction:(NSDictionary * _Nonnull)action param:(NSObject * _Nullable)param body:(id _Nullable)body headers:(NSDictionary * _Nullable)headers success:(SuccessBlock _Nullable)success error:(ErrorBlock _Nullable)error;
- (void)cancel;
- (void)clear;
- (void)sendAsynchronousRequest:(NSURLRequest * _Nonnull)request completion:(CompletionBlock _Nullable)completion;
- (NSData * _Nullable)sendSynchronousRequest:(NSURLRequest * _Nonnull)request returningResponse:(NSHTTPURLResponse * _Nullable * _Nullable)response error:(NSError * _Nullable * _Nullable)error;
- (NSString * _Nullable)paramWithUTF8StringEncoding;
@end

@interface MultipartFormDataObject : NSObject
@property (nonatomic, strong) NSString *  _Nullable filename;
@property (nonatomic, strong) NSString *  _Nullable filetype;
@property (nonatomic, strong) NSData * _Nullable data;
+ (MultipartFormDataObject * _Nonnull)objectWithFilename:(NSString * _Nonnull)filename filetype:(NSString *  _Nonnull)filetype data:(NSData * _Nonnull)data;
@end