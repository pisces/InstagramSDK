//
//  PSFoundation.h
//  PSFoundation
//
//  Created by Steve Kim on 2015. 4. 8..
//  Copyright (c) 2013 Steve Kim. All rights reserved.
//

/*
 Copyright 2015 Steve Kim
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "DBManager.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation DBManager

// ================================================================================================
//  Overridden: NSObject
// ================================================================================================

#pragma mark - Overridden: NSObject

- (id)init
{
    self = [super init];
    if (self)
    {
        _dbQueue = dispatch_queue_create([NSStringFromClass([self class]) cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    _dbQueue = NULL;
}

// ================================================================================================
//  Public
// ================================================================================================

#pragma mark - Class Public methods

+ (DBManager *)sharedInstance
{
    static DBManager *instance;
    static dispatch_once_t precate;
    
    dispatch_once(&precate, ^{
        instance = [[[self class] alloc] init];
    });
    
    return instance;
}

#pragma mark - Public methods

- (NSArray *)arrayWithQuery:(NSString *)query db:(sqlite3 *)db
{
    __block NSArray *result = nil;
    dispatch_sync(_dbQueue, ^{
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
        {
            NSMutableArray *items = [[NSMutableArray alloc] init];
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
                int columnCount = sqlite3_column_count(statement);
                for (int i=0; i<columnCount; i++)
                {
                    int type = sqlite3_column_type(statement, i);
                    id value = [self valueWithType:type statement:statement i:i];
                    NSString *columnName = [NSString stringWithUTF8String:(char *) sqlite3_column_name(statement, i)];
                    
                    if (columnName && value)
                        [item setObject:value forKey:columnName];
                }
                
                [items addObject:item];
            }
            
            sqlite3_finalize(statement);
            result = items;
            return;
        }
        sqlite3_finalize(statement);
    });
    return result;
}

- (id)valueWithType:(int)type statement:(sqlite3_stmt *)statement i:(int)i
{
    char *columnValueChar = (char *) sqlite3_column_text(statement, i);
    
    if (columnValueChar)
        return [NSString stringWithUTF8String:columnValueChar];
    
    return nil;
}

- (void)executeQuery:(NSString *)query db:(sqlite3 *)db target:(id)target success:(SEL)success error:(SEL)error
{
    dispatch_sync(self.dbQueue, ^{
        QueryExecuteObject *object = [QueryExecuteObject objectWith:query db:db target:target success:success error:error];
        NSArray *result = [self arrayWithQuery:object.query db:object.db];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result)
                [object.target performSelector:object.success withObject:result];
            else
                [object.target performSelector:object.error withObject:nil];
        });
    });
}

- (void)executeQuery:(NSString *)query db:(sqlite3 *)db success:(void (^)(NSArray *))success error:(void (^)(NSError *))error
{
    dispatch_sync(self.dbQueue, ^{
        NSArray *result = [self arrayWithQuery:query db:db];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result)
                success(result);
            else
                error(nil);
        });
    });
}

- (BOOL)existFieldWithName:(NSString *)name tableName:(NSString *)tableName db:(sqlite3 *)db
{
    __block BOOL exists = NO;
    
    dispatch_sync(self.dbQueue, ^{
        sqlite3_stmt *statement;
        NSString *query = [NSString stringWithFormat:@"SELECT %@ FROM %@ LIMIT 1;", name, tableName];
        
        if (sqlite3_prepare_v2(db, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
            exists = YES;
        
        sqlite3_finalize(statement);
    });
    
    return exists;
}

- (BOOL)existTableWithName:(NSString *)name db:(sqlite3 *)db
{
    NSString *query = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@';", name];
    NSArray *result = [[DBManager sharedInstance] arrayWithQuery:query db:db];
    return result && result.count > 0;
}

- (BOOL)hasDBWithFilename:(NSString *)filename
{
    __block BOOL result;
    dispatch_sync(self.dbQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *writableDBPath = [fileManager.documentsDirectory stringByAppendingPathComponent:filename];
        result = [fileManager fileExistsAtPath:writableDBPath];
    });
    return result;
}

- (sqlite3 *)openWithDBFilename:(NSString *)dbFilename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *DBPath = [fileManager.documentsDirectory stringByAppendingPathComponent:dbFilename];
    return [self openWithDBPath:DBPath];
}

- (sqlite3 *)openWithDBFilename:(NSString *)dbFilename copyFileName:(NSString *)copyFileName
{
    __block sqlite3 *db = nil;
    dispatch_sync(self.dbQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *coptyDBPath = [fileManager.documentsDirectory stringByAppendingPathComponent:copyFileName];
        
        if (![fileManager fileExistsAtPath:coptyDBPath])
        {
            NSString *srcDBPath = [fileManager.documentsDirectory stringByAppendingPathComponent:dbFilename];
            if ([fileManager fileExistsAtPath:srcDBPath]) {
                NSError *error;
                [fileManager copyItemAtPath:srcDBPath toPath:coptyDBPath error:&error];
                
                if (![fileManager fileExistsAtPath:coptyDBPath])
                    return;
            }
        }
        
        if (sqlite3_open([coptyDBPath UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            return;
        }
    });
    
    [self sqlite3CreateFunctionWithDB:db];
    
    return db;
}

- (sqlite3 *)openWithDBPath:(NSString *)DBPath
{
    __block sqlite3 *db = nil;
    dispatch_sync(self.dbQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL dbexits = [fileManager fileExistsAtPath:DBPath];
        
        if (!dbexits)
            return;
        
        if (sqlite3_open([DBPath UTF8String], &db) != SQLITE_OK) {
            sqlite3_close(db);
            return;
        }
    });
    
    [self sqlite3CreateFunctionWithDB:db];
    
    return db;
}

- (void)sqlite3CreateFunctionWithDB:(sqlite3 *)db
{
    if (db)
    {
        sqlite3_create_function(db, "urldecode", 1, SQLITE_UTF8, NULL, &urldecode, NULL, NULL);
        sqlite3_create_function(db, "urlencode", 1, SQLITE_UTF8, NULL, &urlencode, NULL, NULL);
        
        [self sqlite3CreateCustomFunctionWithDB:db];
    }
}

- (void)sqlite3CreateCustomFunctionWithDB:(sqlite3 *)db
{
}

#pragma mark - C Functions

static void urldecode(sqlite3_context *context, int count, sqlite3_value **val)
{
    if (count == 1)
    {
        const unsigned char *text = sqlite3_value_text(*val);
        if (text)
        {
            NSString *encodedText = [NSString stringWithCString:(const char *) text encoding:NSUTF8StringEncoding];
            const char *result = [[encodedText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] UTF8String];
            sqlite3_result_text(context, result, (int) strlen(result), NULL);
        }
    }
}

static void urlencode(sqlite3_context *context, int count, sqlite3_value **val)
{
    if (count == 1)
    {
        const unsigned char *text = sqlite3_value_text(*val);
        if (text)
        {
            NSString *encodedText = [NSString stringWithCString:(const char *) text encoding:NSUTF8StringEncoding];
            const char *result = [[encodedText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] UTF8String];
            sqlite3_result_text(context, result, (int) strlen(result), NULL);
        }
    }
}
@end

@implementation QueryExecuteObject
@synthesize query, db, target, success, error;
+ (QueryExecuteObject *)objectWith:(NSString *)query db:(sqlite3 *)db target:(id)target success:(SEL)success error:(SEL)error
{
    QueryExecuteObject *object = [[QueryExecuteObject alloc] init];
    object.query = query;
    object.db = db;
    object.target = target;
    object.success = success;
    object.error = error;
    
    return object;
}

- (void)dealloc
{
    query = nil;
    db = nil;
    target = nil;
    success = nil;
    error = nil;
}
@end
