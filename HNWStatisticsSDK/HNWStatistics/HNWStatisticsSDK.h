//
//  HNWStatisticsSDK.h
//  huinongwang
//
//  Created by 杨永正 on 2017/7/25.
//  Copyright © 2017年 cnhnb. All rights reserved.
//

#import "HNWStatisticsConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsSDK : NSObject

@property (class, nonatomic, readonly) NSString *currentSessionId;

/// 初始化统计模块（不要重复调用）
/// @param configuration 初始化时配置
+ (void)initWithConfiguration:(HNWStatisticsConfiguration *)configuration;

/// 启动服务（不要重复调用），在 initWithConfiguration: 之后调用
+ (void)startService;

/// 注册错误捕捉（不要重复调用）
+ (void)registerUncaughtExceptionCrashHandler;

/// 更新统计配置
/// @param configuration 统计配置
+ (void)updateConfiguration:(HNWStatisticsConfiguration *)configuration;

/// 更新个推ID
/// @param clientId 个推ID
+ (void)updateGeTuiClientId:(NSString *)clientId;

/// 手动一键上报所有类型统计日志
+ (void)manualReportingAllLogs:(void(^)(BOOL success))completion;


/// 页面统计
/// @param pageName 页面名称
+ (void)beginLogPageView:(NSString *)pageName;

/// 计数事件统计
/// @param eventId 事件id
+ (void)event:(NSString *)eventId;

/// 计数事件统计
/// @param eventId 事件id
/// @param attributes 附加信息
+ (void)event:(NSString *)eventId attributes:(nullable NSDictionary *)attributes;

/// 事件统计
/// @param eventId 事件Id
/// @param eventType 事件类型
/// @param value 值（计数时为 1，计算时为数量，属性为属性值）
+ (void)event:(NSString *)eventId
    eventType:(HNWStatisticsEventType)eventType
        value:(NSString *)value;

/// 事件统计
/// @param eventId 事件Id
/// @param eventType 事件类型
/// @param value 值（计数时为 1，计算时为数量，属性为属性值）
/// @param attributes 附加信息
+ (void)event:(NSString *)eventId
    eventType:(HNWStatisticsEventType)eventType
        value:(NSString *)value
   attributes:(nullable NSDictionary *)attributes;

/// 页面渲染时长事件统计
/// @param duration 页面渲染时长
/// @param attributes 附带参数键值对
+ (void)pageRenderingDuration:(NSInteger)duration attributes:(nullable NSDictionary *)attributes;

@end

NS_ASSUME_NONNULL_END
