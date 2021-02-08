//
//  HNWStatisticsLogFetchResult.m
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsLogFetchResult.h"

@implementation HNWStatisticsLogFetchResult

+ (instancetype)fetchResultWithError:(NSError *)error {
    HNWStatisticsLogFetchResult *fetchResult = [[[self class] alloc] init];
    fetchResult->_error = [error copy];
    fetchResult->_results = nil;
    fetchResult->_minimumId = 0;
    fetchResult->_maximumId = 0;
    return fetchResult;
}

+ (instancetype)fetchResultWithResults:(NSArray<NSDictionary *> *)results
                             minimumId:(int64_t)minimumId
                             maximumId:(int64_t)maximumId{
    HNWStatisticsLogFetchResult *fetchResult = [[[self class] alloc] init];
    fetchResult->_results = [results copy];
    fetchResult->_minimumId = minimumId;
    fetchResult->_maximumId = maximumId;
    fetchResult->_error = nil;
    return fetchResult;
}

@end
