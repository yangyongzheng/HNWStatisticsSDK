//
//  HNWStatisticsBasicInfo.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsBasicInfo : NSObject
@property (class, nonatomic, readonly, strong) HNWStatisticsBasicInfo *sharedBasicInfo;

/// 用户ID, default value is "0".
@property (nonatomic, readonly, copy) NSString *hnwUserId;
/// app 版本号
@property (nonatomic, readonly, copy) NSString *hnwAppVersion;
/// default value is [NSUserDefaults.hnwSharedUserDefaults stringForKey:HNWUserDefaultsKey(@"deviceId")].
@property (nonatomic, readonly, copy) NSString *hnwDeviceId;
/// default value is "App Store".
@property (nonatomic, readonly, copy) NSString *hnwChannel;

- (void)setHnwUserId:(NSString *)hnwUserId;
@end

NS_ASSUME_NONNULL_END
