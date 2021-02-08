//
//  HNWStatisticsLogDeleteOptions.h
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsLogProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsLogDeleteOptions : NSObject

@property (nonatomic, readonly) int64_t minimumId;
@property (nonatomic, readonly) int64_t maximumId;
@property (nonatomic, readonly) HNWStatisticsLogType logType;

+ (instancetype)optionsWithLogType:(HNWStatisticsLogType)logType
                         minimumId:(int64_t)minimumId
                         maximumId:(int64_t)maximumId;

@end

NS_ASSUME_NONNULL_END
