//
//  HNWStatisticsManager.h
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsManager : NSObject

@property (class, nonatomic, readonly, strong) HNWStatisticsManager *sharedManager;

@property (class, nonatomic, readonly) NSString *currentSessionId;

- (void)startWithConfiguration:(HNWStatisticsConfiguration *)configuration;
- (void)startService;
- (void)registerUncaughtExceptionCrashHandler;
- (void)updateConfiguration:(HNWStatisticsConfiguration *)configuration;
- (void)updateGeTuiClientId:(NSString *)clientId;

/// 页面统计
/// @param pageName 页面名称
- (void)beginLogPageView:(NSString *)pageName;

/// 事件统计
/// @param eventId 事件id
/// @param eventType 事件类型
/// @param value 计数值、计算值或属性值
/// @param attributes 附加信息
- (void)event:(NSString *)eventId
    eventType:(HNWStatisticsEventType)eventType
        value:(NSString *)value
   attributes:(NSDictionary *)attributes;

/// 页面渲染时长事件统计
/// @param duration 页面渲染时长
/// @param attributes 附加信息
- (void)pageRenderingDuration:(NSInteger)duration attributes:(NSDictionary *)attributes;

/// 一键上报日志
/// @param completion 结果回调
- (void)manualReportingAllLogs:(void(^)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
