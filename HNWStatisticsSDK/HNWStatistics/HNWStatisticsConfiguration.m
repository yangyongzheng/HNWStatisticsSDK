//
//  HNWStatisticsConfiguration.m
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsConfiguration.h"

/** 上报间隔时间常量 */
const NSUInteger HNWStatisticsReportIntervalDefault = 120;  // 上报默认间隔时间 120s
const NSUInteger HNWStatisticsReportIntervalMin = 30;       // 上报最小间隔时间 30s
const NSUInteger HNWStatisticsReportIntervalMax = 28800;    // 上报最大间隔时间 28800s(8h)

@implementation HNWStatisticsConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.reportPolicy = HNWStatisticsReportPolicyInterval;
        self.reportInterval = HNWStatisticsReportIntervalDefault;
        self.reportOnlyInWIFI = NO;
    }
    return self;
}

+ (instancetype)defaultConfiguration {
    return [[[self class] alloc] init];
}

- (void)setReportPolicy:(HNWStatisticsReportPolicy)reportPolicy {
    if (reportPolicy == HNWStatisticsReportPolicyLaunch ||
        reportPolicy == HNWStatisticsReportPolicyRealTime ||
        reportPolicy == HNWStatisticsReportPolicyInterval) {
        _reportPolicy = reportPolicy;
    } else {
        _reportPolicy = HNWStatisticsReportPolicyInterval;
    }
}

- (void)setReportInterval:(NSInteger)reportInterval {
    if (reportInterval >= HNWStatisticsReportIntervalMin &&
        reportInterval <= HNWStatisticsReportIntervalMax) {
        _reportInterval = reportInterval;
    } else {
        _reportInterval = HNWStatisticsReportIntervalDefault;
    }
}

@end
