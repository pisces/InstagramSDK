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

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "NSFileManager+PSFoundation.h"

@interface DBManager : NSObject
@property (nonatomic) dispatch_queue_t dbQueue;
+ (DBManager *)sharedInstance;
- (NSArray *)arrayWithQuery:(NSString *)query db:(sqlite3 *)db;
- (void)executeQuery:(NSString *)query db:(sqlite3 *)db target:(id)target success:(SEL)success error:(SEL)error;
- (void)executeQuery:(NSString *)query db:(sqlite3 *)db success:(void (^)(NSArray *result))success error:(void (^)(NSError *error))error;
- (BOOL)existFieldWithName:(NSString *)name tableName:(NSString *)tableName db:(sqlite3 *)db;
- (BOOL)existTableWithName:(NSString *)name db:(sqlite3 *)db;
- (BOOL)hasDBWithFilename:(NSString *)filename;
- (sqlite3 *)openWithDBFilename:(NSString *)dbFilename;
- (sqlite3 *)openWithDBFilename:(NSString *)dbFilename copyFileName:(NSString *)copyFileName;
- (sqlite3 *)openWithDBPath:(NSString *)DBPath;
- (void)sqlite3CreateCustomFunctionWithDB:(sqlite3 *)db;
@end

@interface QueryExecuteObject : NSObject
@property (nonatomic, retain) NSString *query;
@property (nonatomic) sqlite3 *db;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL error;
@property (nonatomic) SEL success;
+ (QueryExecuteObject *)objectWith:(NSString *)query db:(sqlite3 *)db target:(id)target success:(SEL)success error:(SEL)error;
@end