//
//  HNWStatisticsLogFetchResult.h
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsLogFetchResult : NSObject

@property (nullable, nonatomic, readonly, copy) NSArray<NSDictionary *> *results;
@property (nullable, nonatomic, readonly, copy) NSError *error;
@property (nonatomic, readonly) int64_t minimumId;
@property (nonatomic, readonly) int64_t maximumId;

+ (instancetype)fetchResultWithError:(NSError *)error;

+ (instancetype)fetchResultWithResults:(NSArray<NSDictionary *> *)results
                             minimumId:(int64_t)minimumId
                             maximumId:(int64_t)maximumId;

@end

NS_ASSUME_NONNULL_END
