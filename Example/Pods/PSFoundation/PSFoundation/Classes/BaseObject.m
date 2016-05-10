//
//  BaseObject.m
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 ~ 2016 Steve Kim. All rights reserved.
//

#import "BaseObject.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <CoreGraphics/CoreGraphics.h>

@interface BaseObject (AutoCoding)

- (void)setWithCoder:(NSCoder *)aDecoder;

@end

@implementation BaseObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self != nil)
    {
        [self setWithCoder:aDecoder];
    }
    
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        for (NSString *key in [self classProperties]) {
            id value = [self valueForKey:key];
            
            if (!value)
                continue;
            
            if ([value isKindOfClass:[NSObject class]]) {
                NSObject *object = (NSObject *) value;
                NSObject *copiedObject = object.copy;
                
                if (![object isKindOfClass:[copiedObject class]])
                    [copy setValue:object.mutableCopy forKey:key];
                else
                    [copy setValue:copiedObject forKey:key];
            } else {
                [copy setValue:value forKey:key];
            }
        }
    }
    
    return copy;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self classProperties])
    {
        id object = [self valueForKey:key];
        if (object) [aCoder encodeObject:object forKey:key];
    }
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (id)objectFromJSONData:(NSData *)jsonData
{
    if(jsonData == nil) return nil;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:NULL];
}

+ (instancetype)objectWithJSONData:(NSData *)jsonData
{
    id newObject = nil;
    id jsonObject = [[self class] objectFromJSONData:jsonData];
    
    if (jsonObject != nil)
    {
        if ([jsonObject isKindOfClass:[NSDictionary class]])
        {
            newObject = [[self class] objectWithDictionary:jsonObject];
        }
    }
    
    return newObject;
}

+ (instancetype)objectWithJSONString:(NSString *)jsonString
{
    if(jsonString == nil) return nil;
    return [[self class] objectWithJSONData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (instancetype)objectWithDictionary:(NSDictionary *)dictionary
{
    id newObject        = [[[self class] alloc] init];
    
    if(newObject != nil)
    {
        [newObject setDictionary:dictionary];
    }
    
    return newObject;
}

+ (instancetype)objectWithContentsOfFile:(NSString *)filePath
{
    NSData *data    = [NSData dataWithContentsOfFile:filePath];
    
    id object       = nil;
    
    if (data != nil)
    {
        NSPropertyListFormat format;
        if ([NSPropertyListSerialization respondsToSelector:@selector(propertyListWithData:options:format:error:)]) {
            object = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:NULL];
        }
        
		if (object)
		{
			if ([object respondsToSelector:@selector(objectForKey:)] && [object objectForKey:@"$archiver"])
				object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		}
		else
			object  = data;
    }
    
	return object;
}

+ (NSArray *)arrayWithJSONData:(NSData *)jsonData
{
    id newObject = nil;
    id jsonObject = [[self class] objectFromJSONData:jsonData];
    
    if (jsonObject != nil)
    {
        if ([jsonObject isKindOfClass:[NSArray class]])
        {
            NSMutableArray *arr = (NSMutableArray *)jsonObject;
            
            [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 id data = [[self class] objectWithDictionary:obj];
                 if(data != nil) [arr addObject:data];
             }];
            
            newObject = [[NSArray alloc] initWithArray:arr];
        }
    }
    
    return newObject;
}

+ (NSArray *)arrayWithJSONString:(NSString *)jsonString
{
    return [[self class] arrayWithJSONData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSArray *)arrayWithDictionaryArray:(NSArray *)array
{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[array count]];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [arr addObject:[[self class] objectWithDictionary:obj]];
    }];
    
    return arr;
}

- (id)clone
{
    NSData *data = [self archivedData];
    return (data != nil) ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void)setDictionary:(NSDictionary *)dictionary
{
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
         @try
         {
             [self setValue:obj forKey:key];
         }
         @catch (NSException *exception)
         {
             [self exceptionFromDictionary:obj forKey:key];
         }
     }];
}

+ (NSDictionary *)classProperties
{
    @synchronized([self class])
    {
        static NSMutableDictionary *keysByClass = nil;
        if (keysByClass == nil)
        {
            keysByClass = [[NSMutableDictionary alloc] init];
        }
        
        NSString *className = NSStringFromClass(self);
        NSMutableDictionary *codableProperties = [keysByClass objectForKey:className];
        if (codableProperties == nil)
        {

            codableProperties = [NSMutableDictionary dictionary];
            unsigned int propertyCount;
            objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
            for (unsigned int i = 0; i < propertyCount; i++)
            {
                //get property name
                objc_property_t property = properties[i];
                const char *propertyName = property_getName(property);
                NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
                
                //check if codable
                if (![[self uncodableProperties] containsObject:key])
                {
                    //get property type
                    Class class = nil;
                    char *typeEncoding = property_copyAttributeValue(property, "T");
                    switch (typeEncoding[0])
                    {
                        case '@':
                        {
                            if (strlen(typeEncoding) >= 3)
                            {
                                char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                                NSString *name = [NSString stringWithUTF8String:className];
                                NSRange range = [name rangeOfString:@"<"];
                                if (range.location != NSNotFound)
                                {
                                    name = [name substringToIndex:range.location];
                                }
                                class = NSClassFromString(name) ?: [BaseObject class];
                                free(className);
                            }
                            break;
                        }
                        case 'c':
                        case 'i':
                        case 's':
                        case 'l':
                        case 'q':
                        case 'Q':
                        case 'C':
                        case 'I':
                        case 'S':
                        case 'f':
                        case 'd':
                        case 'B':
                        {
                            class = [NSNumber class];
                            break;
                        }
                        case '{':
                        {
                            class = [NSValue class];
                            break;
                        }
                    }
                    free(typeEncoding);
                    
                    if (class)
                    {
                        //see if there is a backing ivar
                        char *ivar = property_copyAttributeValue(property, "V");
                        if (ivar)
                        {
                            char *readonly = property_copyAttributeValue(property, "R");
                            if (readonly)
                            {
                                //check if ivar has KVC-compliant name
                                NSString *ivarName = [NSString stringWithFormat:@"%s", ivar];
                                if ([ivarName isEqualToString:key] ||
                                    [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                                {
                                    //no setter, but setValue:forKey: will still work
                                    codableProperties[key] = class;
                                }
                                free(readonly);
                            }
                            else
                            {
                                //there is a setter method so setValue:forKey: will work
                                codableProperties[key] = class;
                            }
                            free(ivar);
                        }
                    }
                }
            }
            free(properties);
            [keysByClass setObject:[NSDictionary dictionaryWithDictionary:codableProperties] forKey:className];
        }
        return codableProperties;
    }
}

+ (NSArray *)uncodableProperties
{
    return nil;
}

- (NSDictionary *)classProperties
{
    @synchronized([self class])
    {
        static NSMutableDictionary *propertiesByClass = nil;
        if (propertiesByClass == nil)
        {
            propertiesByClass = [[NSMutableDictionary alloc] init];
        }
        
        NSString *className = NSStringFromClass([self class]);
        
        NSDictionary *codableProperties = propertiesByClass[className];
        if (codableProperties == nil)
        {
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            Class class = [self class];
            while (class != [BaseObject class])
            {
                [properties addEntriesFromDictionary:[class classProperties]];
                class = [class superclass];
            }
            codableProperties = [properties copy];
            [propertiesByClass setObject:codableProperties forKey:className];
        }
        return codableProperties;
    }
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[[self classProperties] allKeys]];
}

- (NSData *)JSONData
{
    NSDictionary *dict = [self dictionaryRepresentation];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
}

- (NSString *)JSONString
{
    NSData *data = [self JSONData];
    return (data != nil) ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (NSData *)archivedData
{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    NSData *data = [self archivedData];
    return (data != nil) ? [data writeToFile:filePath atomically:useAuxiliaryFile] : NO;
}

// ================================================================================================
//  Overriden
// ================================================================================================
- (void)exceptionFromDictionary:(id)value forKey:(NSString *)key
{
    
}

@end

@implementation BaseObject (Selector)

+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    if(block == NULL) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        block();
    });
}

- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    [[self class] performBlock:block afterDelay:delay];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (id)safePerformSelector:(SEL)selector
{
    return [self safePerformSelector:selector withObject:nil withObject:nil];
}

- (id)safePerformSelector:(SEL)selector withObject:(id)object
{
    return [self safePerformSelector:selector withObject:object withObject:nil];
}

- (id)safePerformSelector:(SEL)selector withObject:(id)object1 withObject:(id)object2
{
    if([self respondsToSelector:selector])
    {
        return [self performSelector:selector withObject:object1 withObject:object2];
    }
    
    return nil;
}

#pragma clang diagnostic pop

@end

@implementation BaseObject (Dump)

#pragma mark - Superclasses
+ (NSArray *) superclasses
{
    if ([self isEqual:[BaseObject class]]) return @[self];
    
    Class theClass = self;
    NSMutableArray *results = [NSMutableArray arrayWithObject:theClass];
    
    do
    {
        theClass = [theClass superclass];
        [results addObject:theClass];
    }
    while (![theClass isEqual:[BaseObject class]]) ;
    
    return results;
}

// Return an array of an object's superclasses
- (NSArray *) superclasses
{
    return [[self class] superclasses];
}

// Return an array of all an object's properties
+ (NSArray *) getProtocolListForClass
{
	NSMutableArray *protocolNames = [NSMutableArray array];
	unsigned int num;
	Protocol *const *protocols = class_copyProtocolList(self, &num);
	for (int i = 0; i < num; i++)
		[protocolNames addObject:[NSString stringWithCString:protocol_getName(protocols[i]) encoding:NSUTF8StringEncoding]];
	free((void *)protocols);
	return protocolNames;
}

// Return a dictionary with class/selectors entries, all the way up to BaseObject
+ (NSDictionary *) protocols
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getProtocolListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses])
		[dict setObject:[cl getProtocolListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

// Return an array of all an object's properties
+ (NSArray *) getPropertyListForClass
{
	NSMutableArray *propertyNames = [NSMutableArray array];
	unsigned int num;
	objc_property_t *properties = class_copyPropertyList(self, &num);
	for (int i = 0; i < num; i++)
		[propertyNames addObject:[NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding]];
	free(properties);
	return propertyNames;
}

// Return a dictionary with class/selectors entries, all the way up to BaseObject
- (NSDictionary *) properties
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[[self class] getPropertyListForClass] forKey:NSStringFromClass([self class])];
	for (Class cl in [self superclasses])
		[dict setObject:[cl getPropertyListForClass] forKey:NSStringFromClass(cl)];
	return dict;
}

/*
 
 Notes:
 
 objc_property_t prop = class_getProperty(self.class, "foo");
 char *setterName = property_copyAttributeValue(prop, "S");
 printf("%s\n", setterName);
 char *getterName = property_copyAttributeValue(prop, "G");
 printf("%s\n", getterName);
 
 see http://svn.gna.org/svn/gnustep/libs/libobjc2/trunk/properties.m
 T == property_getTypeEncoding(property)
 D == dynamic/synthesized
 V = property_getIVar(property)
 S = property->setter_name
 G = property->getter_name
 R - readonly, W - weak, C - copy, &, retain/strong, N - Nonatomic
 */

// A work in progress
+ (NSString *) typeForString: (const char *) typeName
{
    NSString *typeNameString = @(typeName);
    if ([typeNameString hasPrefix:@"@\""])
    {
        NSRange r = NSMakeRange(2, typeNameString.length - 3);
        NSString *format = [NSString stringWithFormat:@"(%@ *)", [typeNameString substringWithRange:r]];
        return format;
    }
    
    if ([typeNameString isEqualToString:@"v"])
        return @"(void)";
    
    if ([typeNameString isEqualToString:@"@"])
        return @"(id)";
    
    if ([typeNameString isEqualToString:@"^v"])
        return @"(void *)";
    
    if ([typeNameString isEqualToString:@"c"])
        return @"(BOOL)";
    
    if ([typeNameString isEqualToString:@"i"])
        return @"(int)";
    
    if ([typeNameString isEqualToString:@"s"])
        return @"(short)";
    
    if ([typeNameString isEqualToString:@"l"])
        return @"(long)";
    
    if ([typeNameString isEqualToString:@"q"])
        return @"(long long)";
    
    if ([typeNameString isEqualToString:@"I"])
        return @"(unsigned int)";
    
    if ([typeNameString isEqualToString:@"L"])
        return @"(unsigned long)";
    
    if ([typeNameString isEqualToString:@"Q"])
        return @"(unsigned long long)";
    
    if ([typeNameString isEqualToString:@"f"])
        return @"(float)";
    
    if ([typeNameString isEqualToString:@"d"])
        return @"(double)";
    
    if ([typeNameString isEqualToString:@"B"])
        return @"(bool)";
    
    if ([typeNameString isEqualToString:@"*"])
        return @"(char *)";
    
    if ([typeNameString isEqualToString:@"#"])
        return @"(Class)";
    
    if ([typeNameString isEqualToString:@":"])
        return @"(SEL)";
    
    if ([typeNameString isEqualToString:@(@encode(CGPoint))])
        return @"(CGPoint)";
    
    if ([typeNameString isEqualToString:@(@encode(CGSize))])
        return @"(CGSize)";
    
    if ([typeNameString isEqualToString:@(@encode(CGRect))])
        return @"(CGRect)";
    
    if ([typeNameString isEqualToString:@(@encode(CGAffineTransform))])
        return @"(CGAffineTransform)";
    
    if ([typeNameString isEqualToString:@(@encode(UIEdgeInsets))])
        return @"(UIEdgeInsets)";
    
    if ([typeNameString isEqualToString:@(@encode(NSRange))])
        return @"(NSRange)";
    
    if ([typeNameString isEqualToString:@(@encode(CFStringRef))])
        return @"(CFStringRef)";
    
    if ([typeNameString isEqualToString:@(@encode(NSZone *))])
        return @"(NSZone *)";
    
    //    if ([typeNameString isEqualToString:@(@encode(CGAffineTransform))])
    //        return @"(CGAffineTransform)";
    
    
    /*
     [array type]     An array
     {name=type...}     A structure
     (name=type...)     A union
     bnum     A bit field of num bits
     ^type     A pointer to type
     ?     An unknown type (among other things, this code is used for function pointers)
     */
    
    return [NSString stringWithFormat:@"(%@)", typeNameString];
}

+ (NSString *) dump
{
    NSMutableString *dump = [NSMutableString string];
    
    [dump appendFormat:@"%@ ", [[self.superclasses valueForKey:@"description"] componentsJoinedByString:@" : "]];
    
    NSDictionary *protocols = [self protocols];
    NSMutableSet *protocolSet = [NSMutableSet set];
    for (NSString *key in protocols.allKeys)
        [protocolSet addObjectsFromArray:protocols[key]];
    [dump appendFormat:@"<%@>\n", [protocolSet.allObjects componentsJoinedByString:@", "]];
    
    [dump appendString:@"{\n"];
	unsigned int num;
	Ivar *ivars = class_copyIvarList(self, &num);
	for (int i = 0; i < num; i++)
    {
        const char *ivname = ivar_getName(ivars[i]);
        const char *typename = ivar_getTypeEncoding(ivars[i]);
        [dump appendFormat:@"    %@ %s\n", [self typeForString:typename], ivname];
    }
	free(ivars);
    [dump appendString:@"}\n\n"];
    
    BOOL hasProperty = NO;
    NSArray *properties = [self getPropertyListForClass];
    for (NSString *property in properties)
    {
        hasProperty = YES;
        objc_property_t prop = class_getProperty(self, property.UTF8String);
        
        [dump appendString:@"    @property "];
        
        char *nonatomic = property_copyAttributeValue(prop, "N");
        char *readonly = property_copyAttributeValue(prop, "R");
        char *copyAt = property_copyAttributeValue(prop, "C");
        char *strong = property_copyAttributeValue(prop, "&");
        NSMutableArray *attributes = [NSMutableArray array];
        if (nonatomic) [attributes addObject:@"nonatomic"];
        [attributes addObject:strong ? @"strong" : @"assign"];
        [attributes addObject:readonly ? @"readonly" : @"readwrite"];
        if (copyAt) [attributes addObject:@"copy"];
        [dump appendFormat:@"(%@) ", [attributes componentsJoinedByString:@", "]];
        free(nonatomic);
        free(readonly);
        free(copyAt);
        free(strong);
        
        char *typeName = property_copyAttributeValue(prop, "T");
        [dump appendFormat:@"%@ ", [self typeForString:typeName]];
        free(typeName);
        
        char *setterName = property_copyAttributeValue(prop, "S");
        char *getterName = property_copyAttributeValue(prop, "G");
        if (setterName || getterName)
            [dump appendFormat:@"(setter=%s, getter=%s)", setterName, getterName];
        [dump appendFormat:@" %@\n", property];
        free(setterName);
        free(getterName);
    }
    if (hasProperty) [dump appendString:@"\n"];
    
    // Thanks Sam M for arg offset advice.
    
	Method *clMethods = class_copyMethodList(objc_getMetaClass(self.description.UTF8String), &num);
	for (int i = 0; i < num; i++)
    {
        char returnType[1024];
        method_getReturnType(clMethods[i], returnType, 1024);
        NSString *rType = [self typeForString:returnType];
        [dump appendFormat:@"+ %@ ", rType];
        
        NSString *selectorString = NSStringFromSelector(method_getName(clMethods[i]));
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        int argCount = method_getNumberOfArguments(clMethods[i]) - 2;
        if (argCount > 0)
        {
            for (unsigned int j = 0; j < argCount; j++)
            {
                NSString *arg = @"argument";
                char argType[1024];
                method_getArgumentType(clMethods[i], j + 2, argType, 1024);
                NSString *typeStr = [self typeForString:argType];
                [dump appendFormat:@"%@:%@%@ ", components[j], typeStr, arg];
            }
            [dump appendString:@"\n"];
        }
        else
        {
            [dump appendFormat:@"%@\n", selectorString];
        }
    }
	free(clMethods);
    
    [dump appendString:@"\n"];
	Method *methods = class_copyMethodList(self, &num);
	for (int i = 0; i < num; i++)
    {
        char returnType[1024];
        method_getReturnType(methods[i], returnType, 1024);
        NSString *rType = [self typeForString:returnType];
        [dump appendFormat:@"- %@ ", rType];
        
        NSString *selectorString = NSStringFromSelector(method_getName(methods[i]));
        NSArray *components = [selectorString componentsSeparatedByString:@":"];
        int argCount = method_getNumberOfArguments(methods[i]) - 2;
        if (argCount > 0)
        {
            for (unsigned int j = 0; j < argCount; j++)
            {
                NSString *arg = @"argument";
                char argType[1024];
                method_getArgumentType(methods[i], j + 2, argType, 1024);
                NSString *typeStr = [self typeForString:argType];
                [dump appendFormat:@"%@:%@%@ ", components[j], typeStr, arg];
            }
            [dump appendString:@"\n"];
        }
        else
        {
            [dump appendFormat:@"%@\n", selectorString];
        }
    }
	free(methods);
    
    return dump;
}

- (NSString *) dump
{
    return [[self class] dump];
}

@end

@implementation BaseObject (AutoCoding)

- (void)setWithCoder:(NSCoder *)aDecoder
{
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = [[self class] supportsSecureCoding];
    NSDictionary *properties = [self classProperties];
    
    for (NSString *key in properties)
    {
        id object = nil;
        Class class = properties[key];
        
        if (secureAvailable && secureSupported)
            object = [aDecoder decodeObjectOfClass:class forKey:key];
        else
            object = [aDecoder decodeObjectForKey:key];
        
        if (object)
        {
            if ([object isKindOfClass:[NSNull class]])
                [self setValue:[NSNull null] forKey:key];
            else if ([object isKindOfClass:class])
                [self setValue:object forKey:key];
        }
    }
}

@end