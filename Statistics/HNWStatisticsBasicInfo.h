//
//  HNWStatisticsBasicInfo.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsBasicInfo : NSObject

@property (class, nonatomic, readonly, strong) HNWStatisticsBasicInfo *hnwSharedBasicInfo;

/// 用户ID
/// @discussion 默认返回
/// @code
/// [NSUserDefaults.hnwGroupUserDefaults stringForKey:HNWGroupUserDefaultsUserIdKey()]
/// @endcode
/// 否则返回 "0".
@property (nonatomic, readonly, copy) NSString *hnwUserId;

/// 设备号
/// @discussion 默认返回
/// @code
/// [NSUserDefaults.hnwGroupUserDefaults stringForKey:HNWGroupUserDefaultsDeviceIdKey()]
/// @endcode
/// 否则返回 "unknown".
@property (nonatomic, readonly, copy) NSString *hnwDeviceId;

/// app 版本号
@property (nonatomic, readonly, copy) NSString *hnwAppVersion;

/// default value is "App Store".
@property (nonatomic, readonly, copy) NSString *hnwChannel;

@end

NS_ASSUME_NONNULL_END
