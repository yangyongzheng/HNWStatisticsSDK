//
//  HNWStatisticsLogFetchOptions.m
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsLogFetchOptions.h"

@implementation HNWStatisticsLogFetchOptions

- (instancetype)init {
    self = [super init];
    if (self) {
        _ascending = YES;
        _logType = HNWStatisticsLogTypeUnknown;
        _maximumCountLimit = 5000;
    }
    return self;
}

+ (instancetype)optionsWithLogType:(HNWStatisticsLogType)logType maximumCountLimit:(NSUInteger)maximumCountLimit {
    HNWStatisticsLogFetchOptions *opt = [[[self class] alloc] init];
    opt->_logType = logType;
    opt->_maximumCountLimit = maximumCountLimit;
    return opt;
}

@end
