//
//  HNWStatisticsDuration.h
//  huinongwang
//
//  Created by yangyongzheng on 2019/1/17.
//  Copyright © 2019 cnhnb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const HNWSDNetDurationKey;

@interface HNWStatisticsDuration : NSObject

/** 是否需要上报，默认YES */
@property (nonatomic, getter=isReportEnabled) BOOL reportEnabled;

/** 获取当前时间戳，单位毫秒 */
@property (class, nonatomic, readonly) int64_t currentTimestamp;

/**
 存储页面所有接口请求时长，单位毫秒
 数组元素为：[NSNumber numberWithInteger:duration];
 */
@property (nonatomic, readonly, strong) NSMutableArray<NSNumber *> *allRequestDurations;

/**
 添加接口请求时长到数组allRequestDurations
 当 self.isReportEnabled == YES 时，会添加一个NSNumber对象到数组allRequestDurations，并且返回 YES，否则啥都不干，直接返回NO。
 
 @param duration 接口请求时长，当 duration < 0 时，重置为0。
 @return YES-添加成功，NO-添加失败
 */
- (BOOL)addRequestDuration:(NSInteger)duration;

/** 开始渲染页面的时间戳，单位毫秒 */
@property (nonatomic) int64_t startRenderingPageTime;

/** 页面渲染结束的时间戳，单位毫秒 */
@property (nonatomic) int64_t endRenderingPageTime;

/** 页面所有接口请求时长中最大值(即allRequestDurations数组中最大值)，单位毫秒 */
@property (nonatomic, readonly) NSInteger maxRequsetDuration;

/**
 渲染页面时长，单位毫秒
 renderingPageTimeInterval = endRenderingPageTime - startRenderingPageTime
 */
@property (nonatomic, readonly) NSInteger renderingPageTimeInterval;

@end

NS_ASSUME_NONNULL_END
