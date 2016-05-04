/**
 * https://github.com/uacaps/NSObject-ObjectMap/tree/master/NSObject-ObjectMap
 * https://github.com/erica/NSObject-Utility-Categories
 */

#import <Foundation/Foundation.h>

@interface BaseObject : NSObject <NSCoding, NSSecureCoding, NSCopying>

+ (instancetype)objectWithJSONData:(NSData *)jsonData;
+ (instancetype)objectWithJSONString:(NSString *)jsonString;
+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary;
+ (instancetype)objectWithContentsOfFile:(NSString *)filePath;

+ (NSArray *)arrayWithJSONData:(NSData *)jsonData;
+ (NSArray *)arrayWithJSONString:(NSString *)jsonString;
+ (NSArray *)arrayWithDictionaryArray:(NSArray *)array;
- (void)setDictionary:(NSDictionary *)dictionary;

- (id)clone;
- (NSDictionary *)classProperties;
- (NSDictionary *)dictionaryRepresentation;

- (NSData *)JSONData;
- (NSString *)JSONString;
- (NSData *)archivedData;
- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile;

// ================================================================================================
//  Overriden
// ================================================================================================
- (void)exceptionFromDictionary:(id)value forKey:(NSString *)key;

@end

@interface BaseObject (Selector)

+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

- (id)safePerformSelector:(SEL)selector;
- (id)safePerformSelector:(SEL)selector withObject:(id)object;
- (id)safePerformSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2;

@end

@interface BaseObject (Dump)

// Return all superclasses of class or object
+ (NSArray *) superclasses;
- (NSArray *) superclasses;
+ (NSString *) dump;
- (NSString *) dump;

@end