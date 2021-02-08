//
//  HNWStatisticsLogProvider.h
//  HNWCore
//
//  Created by Young on 2020/3/20.
//  Copyright © 2020 Young. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, HNWStatisticsLogType) {
    HNWStatisticsLogTypeUnknown = 0,
    HNWStatisticsLogTypeStart,
    HNWStatisticsLogTypePage,
    HNWStatisticsLogTypeEvent,
    HNWStatisticsLogTypeCrash,
};

@protocol HNWStatisticsLogProvider <NSObject>

@property (nonatomic, readonly) HNWStatisticsLogType logType;
@property (nullable, nonatomic, readonly, copy) NSDictionary *JSONDictionary;

@property (nonatomic, copy) NSString *appVersion;   // 版本号
@property (nonatomic, copy) NSString *channel;      // 渠道号
@property (nonatomic, copy) NSString *deviceId;     // 设备唯一标识
@property (nonatomic, copy) NSString *hnUserId;     // 惠农用户id

@end

NS_ASSUME_NONNULL_END
