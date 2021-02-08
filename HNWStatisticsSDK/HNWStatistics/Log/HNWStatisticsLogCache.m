//
//  HNWStatisticsLogCache.m
//  HNWCore
//
//  Created by Young on 2020/3/20.
//  Copyright © 2020 Young. All rights reserved.
//

/**
 数据库表：Start / Page / Event / Crash
 表字段：pkid / body / createTime
 */

#import "HNWStatisticsLogCache.h"

#define HNWStatisticsLogCacheCompletion(result) \
    do {                                        \
        if (completion) {                       \
            [self safeSyncMainQueue:^{          \
                completion(result);             \
            }];                                 \
        }                                       \
    } while (0)

static NSString * const HNWStatisticsLogTableStart = @"Start";
static NSString * const HNWStatisticsLogTablePage = @"Page";
static NSString * const HNWStatisticsLogTableEvent = @"Event";
static NSString * const HNWStatisticsLogTableCrash = @"Crash";

typedef NS_ENUM(NSInteger, HNWStatisticsLogCacheErrorCode) {
    HNWStatisticsLogCacheErrorCodeParam = 10000,
    HNWStatisticsLogCacheErrorCodeFailed,
};

@interface HNWStatisticsLogCache ()
@property (class, nonatomic, readonly) HNWStatisticsLogCache *sharedLogCache;

@property (nonatomic, readonly, strong) FMDatabaseQueue *dbQueue;
@property (nonatomic, readonly, strong) dispatch_queue_t taskQueue;
@end

@implementation HNWStatisticsLogCache

- (instancetype)init {
    if (self = [super init]) {
        _taskQueue = dispatch_queue_create("com.cnhnb.huinongwang.statisticsLogCache", DISPATCH_QUEUE_SERIAL);
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self databasePath]];
        [self setupEnvironment];
    }
    return self;
}

+ (HNWStatisticsLogCache *)sharedLogCache {
    static HNWStatisticsLogCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[HNWStatisticsLogCache alloc] init];
    });
    return cache;
}

- (void)dealloc {
    if (_dbQueue) {
        [_dbQueue close];
    }
}

- (NSString *)databasePath {
    NSString *baseDirectoryPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *directoryPath = [baseDirectoryPath stringByAppendingPathComponent:@"HNWUserData"];
    BOOL isDir = NO;
    if ([NSFileManager.defaultManager fileExistsAtPath:directoryPath isDirectory:&isDir] && isDir) {/* Do nothing */} else {
        [NSFileManager.defaultManager createDirectoryAtPath:directoryPath
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
    }
    return [directoryPath stringByAppendingPathComponent:@"HNWStatisticsLogs.db"];
}

+ (NSArray<NSString *> *)supportedTableNames {
    return @[
        HNWStatisticsLogTableStart,
        HNWStatisticsLogTablePage,
        HNWStatisticsLogTableEvent,
        HNWStatisticsLogTableCrash,
    ];
}

- (void)setupEnvironment {
    dispatch_async(self.taskQueue, ^{
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSArray *supportedTableNames = [HNWStatisticsLogCache supportedTableNames];
            for (NSString *tableName in supportedTableNames) {
                if ([db tableExists:tableName]) {
                    /* 暂不支持添加或删除表字段 */
                } else {
                    NSString *sql = [HNWStatisticsLogCache createTableSqlStatement:tableName];
                    BOOL result = [db executeUpdate:sql];
                    NSAssert(result, @"数据库 HNWStatisticsLogs 创建表 %@ 失败!", tableName);
                }
            }
        }];
    });
}

+ (NSString *)createTableSqlStatement:(NSString *)tableName {
    NSArray *fieldPartArray = @[
        @"pkid INTEGER PRIMARY KEY AUTOINCREMENT",
        @"body BLOB NOT NULL",
        @"createTime INTEGER DEFAULT (strftime('%s','now'))",
    ];
    NSString *fieldPart = [fieldPartArray componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (%@);", tableName, fieldPart];
}

+ (NSString *)tableNameWithType:(HNWStatisticsLogType)logType {
    if (logType == HNWStatisticsLogTypeStart) {
        return HNWStatisticsLogTableStart;
    } else if (logType == HNWStatisticsLogTypePage) {
        return HNWStatisticsLogTablePage;
    } else if (logType == HNWStatisticsLogTypeEvent) {
        return HNWStatisticsLogTableEvent;
    } else if (logType == HNWStatisticsLogTypeCrash) {
        return HNWStatisticsLogTableCrash;
    } else {
        return nil;
    }
}

+ (BOOL)isValidLogProvider:(id<HNWStatisticsLogProvider>)logProvider {
    BOOL flag = logProvider && [logProvider respondsToSelector:@selector(logType)] && [logProvider respondsToSelector:@selector(JSONDictionary)];
    return flag && [self tableNameWithType:logProvider.logType] && [self dictionaryNotEmpty:logProvider.JSONDictionary];
}

+ (BOOL)isValidFetchOptions:(HNWStatisticsLogFetchOptions *)options {
    return options && [options isKindOfClass:[HNWStatisticsLogFetchOptions class]] &&
    [self tableNameWithType:options.logType] && options.maximumCountLimit > 0;
}

+ (BOOL)isValidDeleteOptions:(HNWStatisticsLogDeleteOptions *)options {
    return options && [options isKindOfClass:[HNWStatisticsLogDeleteOptions class]] &&
    [self tableNameWithType:options.logType] && options.minimumId >= 0 && options.maximumId >= options.minimumId;
}

+ (BOOL)dictionaryNotEmpty:(NSDictionary *)dictionary {
    return dictionary && [dictionary isKindOfClass:[NSDictionary class]] && dictionary.count > 0;
}

+ (NSError *)errorWithCode:(HNWStatisticsLogCacheErrorCode)code {
    if (code == HNWStatisticsLogCacheErrorCodeParam) {
        return [NSError errorWithDomain:@"一个或多个入参无效" code:code userInfo:@{NSLocalizedDescriptionKey:@"一个或多个入参无效"}];
    } else {
        return [NSError errorWithDomain:@"操作数据库失败" code:code userInfo:@{NSLocalizedDescriptionKey:@"操作数据库失败"}];
    }
}

+ (NSData *)JSONDataWithDictionary:(NSDictionary *)dictionary {
    if ([self dictionaryNotEmpty:dictionary]) {
        return [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:nil];
    }
    return nil;
}

+ (NSDictionary *)dictionaryWithJSONData:(NSData *)data {
    if (data && [data isKindOfClass:[NSData class]] && data.length > 0) {
        return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    }
    return nil;
}

+ (void)safeSyncMainQueue:(dispatch_block_t)block {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

#pragma mark - Public
+ (void)saveLog:(id<HNWStatisticsLogProvider>)log completion:(void (^)(NSError * _Nullable))completion {
    if ([self isValidLogProvider:log]) {
        dispatch_async(HNWStatisticsLogCache.sharedLogCache.taskQueue, ^{
            __block BOOL success = YES;
            [HNWStatisticsLogCache.sharedLogCache.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                NSString *tableName = [self tableNameWithType:log.logType];
                NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (body) VALUES (?);", tableName];
                success = [db executeUpdate:sql, [self JSONDataWithDictionary:log.JSONDictionary]];
            }];
            HNWStatisticsLogCacheCompletion(success ? nil : [self errorWithCode:HNWStatisticsLogCacheErrorCodeFailed]);
        });
    } else {
        HNWStatisticsLogCacheCompletion([self errorWithCode:HNWStatisticsLogCacheErrorCodeParam]);
    }
}

+ (void)saveCrashLog:(id<HNWStatisticsLogProvider>)log completion:(void (NS_NOESCAPE ^)(NSError * _Nullable))completion {
    if ([self isValidLogProvider:log]) {
        __block BOOL success = YES;
        [HNWStatisticsLogCache.sharedLogCache.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            NSString *tableName = [self tableNameWithType:log.logType];
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (body) VALUES (?);", tableName];
            success = [db executeUpdate:sql, [self JSONDataWithDictionary:log.JSONDictionary]];
        }];
        HNWStatisticsLogCacheCompletion(success ? nil : [self errorWithCode:HNWStatisticsLogCacheErrorCodeFailed]);
    } else {
        HNWStatisticsLogCacheCompletion([self errorWithCode:HNWStatisticsLogCacheErrorCodeParam]);
    }
}

+ (void)saveLogs:(NSArray<id<HNWStatisticsLogProvider>> *)logs completion:(void (^)(NSError * _Nullable))completion {
    if (logs && [logs isKindOfClass:[NSArray class]] && logs.count > 0) {
        NSArray *safeLogs = [logs copy];
        dispatch_async(HNWStatisticsLogCache.sharedLogCache.taskQueue, ^{
            __block BOOL success = YES;
            [HNWStatisticsLogCache.sharedLogCache.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
                for (id<HNWStatisticsLogProvider> log in safeLogs) {
                    if ([self isValidLogProvider:log]) {
                        NSString *tableName = [self tableNameWithType:log.logType];
                        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (body) VALUES (?);", tableName];
                        if ([db executeUpdate:sql, [self JSONDataWithDictionary:log.JSONDictionary]]) {
                            /* save success */
                        } else {
                            success = NO;
                        }
                    } else {
                        success = NO;
                    }
                    if (!success) {
                        *rollback = YES;
                        break;
                    }
                }
            }];
            HNWStatisticsLogCacheCompletion(success ? nil : [self errorWithCode:HNWStatisticsLogCacheErrorCodeFailed]);
        });
    } else {
        HNWStatisticsLogCacheCompletion([self errorWithCode:HNWStatisticsLogCacheErrorCodeParam]);
    }
}

+ (void)fetchLogsWithOptions:(HNWStatisticsLogFetchOptions *)options completion:(void (^)(HNWStatisticsLogFetchResult * _Nonnull))completion {
    if (!completion) {
        return;
    }
    if ([self isValidFetchOptions:options]) {
        dispatch_async(HNWStatisticsLogCache.sharedLogCache.taskQueue, ^{
            __block HNWStatisticsLogFetchResult *fetchResult = nil;
            [HNWStatisticsLogCache.sharedLogCache.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                NSString *tableName = [self tableNameWithType:options.logType];
                NSString *orderBy = options.isAscending ? @"ASC" : @"DESC";
                NSString *sql = [NSString stringWithFormat:@"SELECT pkid, body FROM %@ ORDER BY pkid %@ LIMIT %ld;", tableName, orderBy, options.maximumCountLimit];
                FMResultSet *resSet = [db executeQuery:sql];
                if (resSet && [resSet isKindOfClass:[FMResultSet class]]) {
                    NSMutableArray *jsonArray = [NSMutableArray array];
                    int64_t minimumId = 0, maximumId = 0;
                    BOOL firstFlag = YES;
                    while ([resSet next]) {
                        int64_t pkid =[resSet longLongIntForColumn:@"pkid"];
                        NSData *data = [resSet dataForColumn:@"body"];
                        if (options.isAscending) {
                            maximumId = pkid;
                            if (firstFlag) {
                                firstFlag = NO;
                                minimumId = pkid;
                            }
                        } else {
                            minimumId = pkid;
                            if (firstFlag) {
                                firstFlag = NO;
                                maximumId = pkid;
                            }
                        }
                        NSDictionary *dict = [self dictionaryWithJSONData:data];
                        if (dict) {[jsonArray addObject:dict];}
                    }
                    fetchResult = [HNWStatisticsLogFetchResult fetchResultWithResults:[jsonArray copy]
                                                                            minimumId:minimumId
                                                                            maximumId:maximumId];
                } else {
                    fetchResult = [HNWStatisticsLogFetchResult fetchResultWithError:[self errorWithCode:HNWStatisticsLogCacheErrorCodeFailed]];
                }
            }];
            HNWStatisticsLogCacheCompletion(fetchResult);
        });
    } else {
        HNWStatisticsLogCacheCompletion([HNWStatisticsLogFetchResult fetchResultWithError:[self errorWithCode:HNWStatisticsLogCacheErrorCodeParam]]);
    }
}

+ (void)deleteLogsWithOptions:(HNWStatisticsLogDeleteOptions *)options completion:(void (^)(NSError * _Nullable))completion {
    if ([self isValidDeleteOptions:options]) {
        dispatch_async(HNWStatisticsLogCache.sharedLogCache.taskQueue, ^{
            __block BOOL success = YES;
            [HNWStatisticsLogCache.sharedLogCache.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
                NSString *tableName = [self tableNameWithType:options.logType];
                NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE pkid >= %lld AND pkid <= %lld;", tableName, options.minimumId, options.maximumId];
                success = [db executeUpdate:sql];
            }];
            HNWStatisticsLogCacheCompletion(success ? nil : [self errorWithCode:HNWStatisticsLogCacheErrorCodeFailed]);
        });
    } else {
        HNWStatisticsLogCacheCompletion([self errorWithCode:HNWStatisticsLogCacheErrorCodeParam]);
    }
}


@end
