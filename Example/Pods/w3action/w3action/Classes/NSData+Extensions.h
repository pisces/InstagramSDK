#import <Foundation/Foundation.h>
#import <zlib.h>
//#import "JSONKit.h"

void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength);

char *NewBase64Encode(
                      const void *inputBuffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength);

@interface NSData (com_pisces_lib_w3action)
- (NSDictionary *)dictionaryWithUTF8JSONString;
+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;



// ================================================================================================
//  base64.h
//  ViewTransitions
//
//  Created by Neo on 5/11/08.
//  Copyright 2008 Kaliware, LLC. All rights reserved.
//
// FOUND HERE http://idevkit.com/forums/tutorials-code-samples-sdk/8-nsdata-base64-extension.html
// ================================================================================================
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;

- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;
@end
