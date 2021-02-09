//
//  HNWStatisticsConfiguration.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import "HNWStatisticsDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsConfiguration : NSObject <NSCopying>

/// 默认配置，非单例对象
@property (class, nonatomic, readonly, strong) HNWStatisticsConfiguration *hnwDefaultConfiguration;

/// 日志上报策略
@property (nonatomic) HNWStatisticsReportPolicy hnwReportPolicy;
/// 间隔上报时间（间隔发送策略时有效），取值范围 [30s 28800s]，默认值 60s
@property (nonatomic) NSInteger hnwReportInterval;
/// 是否仅在 WIFI 下上报，默认值 NO
@property (nonatomic) BOOL hnwIsReportOnlyInWIFI;

@end

NS_ASSUME_NONNULL_END
