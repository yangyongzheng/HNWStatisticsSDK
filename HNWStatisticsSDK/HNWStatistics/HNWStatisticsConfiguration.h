//
//  HNWStatisticsConfiguration.h
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** 上报间隔时间常量 */
FOUNDATION_EXTERN const NSUInteger HNWStatisticsReportIntervalDefault;  // 上报默认间隔时间 120s
FOUNDATION_EXTERN const NSUInteger HNWStatisticsReportIntervalMin;      // 上报最小间隔时间 30s
FOUNDATION_EXTERN const NSUInteger HNWStatisticsReportIntervalMax;      // 上报最大间隔时间 28800s(8h)

/** 数据上报策略 */
typedef NS_ENUM(NSUInteger, HNWStatisticsReportPolicy) {
    HNWStatisticsReportPolicyLaunch = 0,  // 启动发送
    HNWStatisticsReportPolicyRealTime,    // 实时发送
    HNWStatisticsReportPolicyInterval,    // 间隔发送(默认), 取值范围30s-28800s(8hours), 默认 120s.
};

/** 事件统计类型 */
typedef NS_ENUM(NSUInteger, HNWStatisticsEventType) {
    HNWStatisticsEventTypeCount = 1,    // 计数
    HNWStatisticsEventTypeCalculation,  // 计算
    HNWStatisticsEventTypeAttributes,   // 属性
};

@interface HNWStatisticsConfiguration : NSObject

// 默认配置，非单例对象
+ (instancetype)defaultConfiguration;

// 服务器可配置属性
@property (nonatomic) HNWStatisticsReportPolicy reportPolicy;               // 上报策略
@property (nonatomic) NSInteger reportInterval;                             // 上报间隔时间(间隔发送策略)，取值范围[30s 28800s]
@property (nonatomic, getter=isReportOnlyInWIFI) BOOL reportOnlyInWIFI;     // 是否仅在WI-FI下上报

@end

NS_ASSUME_NONNULL_END
