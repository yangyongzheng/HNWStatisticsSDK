//
//  HNWStatisticsDefines.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#ifndef HNWStatisticsDefines_h
#define HNWStatisticsDefines_h

#import <Foundation/Foundation.h>

/** 数据上报策略 */
typedef NS_OPTIONS(NSUInteger, HNWStatisticsReportPolicy) {
    /// App启动发送
    HNWStatisticsReportPolicyLaunch         = 1 << 0,
    /// 实时发送
    HNWStatisticsReportPolicyRealTime       = 1 << 1,
    /// 间隔发送
    HNWStatisticsReportPolicyInterval       = 1 << 2,
    /// 进入后台发送
    HNWStatisticsReportPolicyBackground     = 1 << 3,
    /// App终止发送
    HNWStatisticsReportPolicyTermination    = 1 << 4
};

/** 事件统计类型 */
typedef NS_ENUM(NSUInteger, HNWStatisticsEventType) {
    HNWStatisticsEventTypeCount = 1,    // 计数
    HNWStatisticsEventTypeCalculation,  // 计算
    HNWStatisticsEventTypeAttributes,   // 属性
};

#endif /* HNWStatisticsDefines_h */
