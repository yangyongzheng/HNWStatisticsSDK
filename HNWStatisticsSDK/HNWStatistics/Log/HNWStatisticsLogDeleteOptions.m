//
//  HNWStatisticsLogDeleteOptions.m
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsLogDeleteOptions.h"

@implementation HNWStatisticsLogDeleteOptions

- (instancetype)init {
    self = [super init];
    if (self) {
        _minimumId = 0;
        _maximumId = 0;
        _logType = HNWStatisticsLogTypeUnknown;
    }
    return self;
}

+ (instancetype)optionsWithLogType:(HNWStatisticsLogType)logType
                         minimumId:(int64_t)minimumId
                         maximumId:(int64_t)maximumId {
    HNWStatisticsLogDeleteOptions *opt = [[[self class] alloc] init];
    opt->_logType = logType;
    opt->_minimumId = minimumId;
    opt->_maximumId = maximumId;
    return opt;
}

@end
