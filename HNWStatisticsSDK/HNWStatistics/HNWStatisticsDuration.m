//
//  HNWStatisticsDuration.m
//  huinongwang
//
//  Created by yangyongzheng on 2019/1/17.
//  Copyright © 2019 cnhnb. All rights reserved.
//

#import "HNWStatisticsDuration.h"

NSString * const HNWSDNetDurationKey = @"net_duration";

@interface HNWStatisticsDuration ()
@property (nonatomic, readwrite, strong) NSMutableArray<NSNumber *> *allRequestDurations;
@end

@implementation HNWStatisticsDuration

- (instancetype)init {
    self = [super init];
    if (self) {
        self.reportEnabled = YES;
    }
    return self;
}

+ (int64_t)currentTimestamp {
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    return (int64_t)timestamp;
}

- (NSMutableArray<NSNumber *> *)allRequestDurations {
    if (!_allRequestDurations) {
        _allRequestDurations = [NSMutableArray array];
    }
    return _allRequestDurations;
}

- (BOOL)addRequestDuration:(NSInteger)duration {
    if (self.isReportEnabled) {
        if (duration < 0) {duration = 0;}
        [self.allRequestDurations addObject:[NSNumber numberWithInteger:duration]];
        return YES;
    }
    
    return NO;
}

- (NSInteger)maxRequsetDuration {
    if (self.allRequestDurations.count > 0) {
        return [[self.allRequestDurations valueForKeyPath:@"@max.integerValue"] integerValue];
    }
    
    return 0;
}

- (NSInteger)renderingPageTimeInterval {
    NSInteger interval = (long)(self.endRenderingPageTime - self.startRenderingPageTime);
    return interval >= 0 ? interval : 0;
}

@end
