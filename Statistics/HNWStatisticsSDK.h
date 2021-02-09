//
//  HNWStatisticsSDK.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import "HNWStatisticsConfiguration.h"
#import "HNWStatisticsLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsSDK : NSObject

@property (class, nonatomic, readonly) NSString *currentSessionId;

// MARK: - 初始化
/// 开启统计模块（不要重复调用）
/// @param configuration 初始化所用配置
+ (void)startWithConfiguration:(HNWStatisticsConfiguration *)configuration;

/// 启动服务（不要重复调用），在 startWithConfiguration: 之后调用
+ (void)openService;

/// 注册错误捕捉（不要重复调用）
+ (void)registerUncaughtExceptionCrashHandler;


// MARK: - 设置基本信息
/// 更新统计配置
+ (void)updateConfiguration:(HNWStatisticsConfiguration *)configuration;

/// 设置个推id
/// @param clientId 个推id
+ (void)setGeTuiClientId:(nullable NSString *)clientId;

/// 设置用户唯一标识id
+ (void)setUserUniqueId:(nullable NSString *)userId;

/// 设置用户位置
+ (void)setUserLocation:(nullable HNWStatisticsLocation *)userLocation;


// MARK: - 统计埋点API
/// 页面统计
/// @param pageName 页面名称
+ (void)beginLogPageView:(NSString *)pageName;

/// 页面渲染时长事件统计
/// @param duration 页面渲染时长
/// @param attributes 附带参数键值对
+ (void)pageRenderingDuration:(NSInteger)duration
                   attributes:(nullable NSDictionary *)attributes;

/// 计数事件统计
/// @param eventId 事件id
+ (void)event:(NSString *)eventId;

/// 计数事件统计
/// @param eventId 事件id
/// @param attributes 附加信息
+ (void)event:(NSString *)eventId
   attributes:(nullable NSDictionary *)attributes;

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

@end

NS_ASSUME_NONNULL_END
