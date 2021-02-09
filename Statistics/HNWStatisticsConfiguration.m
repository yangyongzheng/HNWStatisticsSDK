//
//  HNWStatisticsConfiguration.m
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import "HNWStatisticsConfiguration.h"

// 间隔上报间隔时间常量
/// 默认间隔时间 60s
static const NSInteger HNWStatisticsReportIntervalDefault = 60;
/// 最小间隔时间 30s
static const NSInteger HNWStatisticsReportIntervalMin = 30;
/// 最大间隔时间 28800s(8h)
static const NSInteger HNWStatisticsReportIntervalMax = 28800;

@implementation HNWStatisticsConfiguration

- (id)copyWithZone:(NSZone *)zone {
    HNWStatisticsConfiguration *copyInstance = [[[self class] alloc] init];
    copyInstance.hnwReportPolicy = self.hnwReportPolicy;
    copyInstance.hnwReportInterval = self.hnwReportInterval;
    copyInstance.hnwIsReportOnlyInWIFI = self.hnwIsReportOnlyInWIFI;
    return copyInstance;
}

+ (HNWStatisticsConfiguration *)hnwDefaultConfiguration {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hnwReportPolicy = (HNWStatisticsReportPolicyLaunch |
                                HNWStatisticsReportPolicyRealTime |
                                HNWStatisticsReportPolicyBackground |
                                HNWStatisticsReportPolicyTermination);
        self.hnwReportInterval = HNWStatisticsReportIntervalDefault;
        self.hnwIsReportOnlyInWIFI = NO;
    }
    return self;
}

- (void)setHnwReportInterval:(NSInteger)hnwReportInterval {
    if (hnwReportInterval >= HNWStatisticsReportIntervalMin &&
        hnwReportInterval <= HNWStatisticsReportIntervalMax) {
        _hnwReportInterval = hnwReportInterval;
    } else {
        _hnwReportInterval = HNWStatisticsReportIntervalDefault;
    }
}

@end
