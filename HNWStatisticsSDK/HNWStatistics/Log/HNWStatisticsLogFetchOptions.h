//
//  HNWStatisticsLogFetchOptions.h
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsLogProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsLogFetchOptions : NSObject

/** 升序，默认值 YES */
@property (nonatomic, readonly, getter=isAscending) BOOL ascending;

/** 查询最大条数限制，默认值5000 */
@property (nonatomic, readonly) NSUInteger maximumCountLimit;

/** 日志类型，默认值 HNWStatisticsLogTypeUnknown */
@property (nonatomic, readonly) HNWStatisticsLogType logType;

+ (instancetype)optionsWithLogType:(HNWStatisticsLogType)logType maximumCountLimit:(NSUInteger)maximumCountLimit;

@end

NS_ASSUME_NONNULL_END
