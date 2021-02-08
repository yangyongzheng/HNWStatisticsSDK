//
//  UIViewController+HNWStatistics.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (HNWStatistics)

/// 是否统计当前页面，默认值 NO
@property (nonatomic, readonly) BOOL hnwIsRequiredStatistics;

@end

NS_ASSUME_NONNULL_END
