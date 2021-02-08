//
//  HNWStatisticsSDK.m
//  huinongwang
//
//  Created by 杨永正 on 2017/7/25.
//  Copyright © 2017年 cnhnb. All rights reserved.
//

#import "HNWStatisticsSDK.h"
#import "HNWStatisticsManager.h"

@implementation HNWStatisticsSDK

+ (void)initWithConfiguration:(HNWStatisticsConfiguration *)configuration {
    [HNWStatisticsManager.sharedManager startWithConfiguration:configuration];
}

+ (void)startService {
    [HNWStatisticsManager.sharedManager startService];
}

+ (void)registerUncaughtExceptionCrashHandler {
    [HNWStatisticsManager.sharedManager registerUncaughtExceptionCrashHandler];
}

+ (NSString *)currentSessionId {
    return HNWStatisticsManager.currentSessionId;
}

+ (void)updateConfiguration:(HNWStatisticsConfiguration *)configuration {
    [HNWStatisticsManager.sharedManager updateConfiguration:configuration];
}

+ (void)updateGeTuiClientId:(NSString *)clientId {
    [HNWStatisticsManager.sharedManager updateGeTuiClientId:clientId];
}

+ (void)manualReportingAllLogs:(void (^)(BOOL))completion {
    [HNWStatisticsManager.sharedManager manualReportingAllLogs:completion];
}

#pragma mark - Page统计
+ (void)beginLogPageView:(NSString *)pageName {
    [HNWStatisticsManager.sharedManager beginLogPageView:pageName];
}

#pragma mark - 事件统计
+ (void)event:(NSString *)eventId {
    [self event:eventId attributes:nil];
}

+ (void)event:(NSString *)eventId attributes:(NSDictionary *)attributes {
    [self event:eventId
      eventType:HNWStatisticsEventTypeCount
          value:@"1"
     attributes:attributes];
}

+ (void)event:(NSString *)eventId
    eventType:(HNWStatisticsEventType)eventType
        value:(NSString *)value {
    [self event:eventId
      eventType:eventType
          value:value
     attributes:nil];
}

+ (void)event:(NSString *)eventId
    eventType:(HNWStatisticsEventType)eventType
        value:(NSString *)value
   attributes:(NSDictionary *)attributes {
    [HNWStatisticsManager.sharedManager event:eventId
                                    eventType:eventType
                                        value:value
                                   attributes:attributes];
}

+ (void)pageRenderingDuration:(NSInteger)duration attributes:(NSDictionary *)attributes {
    [HNWStatisticsManager.sharedManager pageRenderingDuration:duration attributes:attributes];
}

@end
