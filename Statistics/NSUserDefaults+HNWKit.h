//
//  NSUserDefaults+HNWKit.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 默认组中 设备号 key
FOUNDATION_EXPORT NSString * const HNWGroupUserDefaultsDeviceIdKey(void);
/// 默认组中 用户ID key
FOUNDATION_EXPORT NSString * const HNWGroupUserDefaultsUserIdKey(void);


/// 获取默认组中 key
FOUNDATION_EXPORT NSString * const HNWGroupUserDefaultsKey(NSString *key);



@interface NSUserDefaults (HNWKit)

/// 默认组
@property (class, readonly, strong) NSUserDefaults *hnwGroupUserDefaults;

@end

NS_ASSUME_NONNULL_END
