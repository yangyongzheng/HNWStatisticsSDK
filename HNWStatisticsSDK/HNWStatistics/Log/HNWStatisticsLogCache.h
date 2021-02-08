//
//  HNWStatisticsLogCache.h
//  HNWCore
//
//  Created by Young on 2020/3/20.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsLogProvider.h"
#import "HNWStatisticsLogFetchOptions.h"
#import "HNWStatisticsLogDeleteOptions.h"
#import "HNWStatisticsLogFetchResult.h"
#import <FMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsLogCache : NSObject

+ (void)saveLog:(id<HNWStatisticsLogProvider>)log completion:(void (^)(NSError * _Nullable error))completion;

+ (void)saveCrashLog:(id<HNWStatisticsLogProvider>)log completion:(void (NS_NOESCAPE ^)(NSError * _Nullable error))completion;

+ (void)saveLogs:(NSArray<id<HNWStatisticsLogProvider>> *)logs completion:(void (^)(NSError * _Nullable error))completion;

+ (void)fetchLogsWithOptions:(HNWStatisticsLogFetchOptions *)options completion:(void (^)(HNWStatisticsLogFetchResult *fetchResult))completion;

+ (void)deleteLogsWithOptions:(HNWStatisticsLogDeleteOptions *)options completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
