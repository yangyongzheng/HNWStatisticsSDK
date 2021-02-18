//
//  HNWStatisticsBasicInfo.m
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import "HNWStatisticsBasicInfo.h"
#import "NSUserDefaults+HNWKit.h"

@implementation HNWStatisticsBasicInfo

@synthesize hnwUserId = _hnwUserId;
@synthesize hnwDeviceId = _hnwDeviceId;

+ (HNWStatisticsBasicInfo *)hnwSharedBasicInfo {
    static HNWStatisticsBasicInfo *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HNWStatisticsBasicInfo alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hnwUserId = [self hnwStringForUserId];
        _hnwDeviceId = [self hnwStringForDeviceId];
        _hnwAppVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _hnwChannel = @"App Store";
    }
    return self;
}

- (NSString *)hnwUserId {
    return [self hnwStringForUserId];
}

- (NSString *)hnwDeviceId {
    return [self hnwStringForDeviceId];
}

- (NSString *)hnwStringForDeviceId {
    NSString *deviceId = [NSUserDefaults.hnwGroupUserDefaults stringForKey:HNWGroupUserDefaultsDeviceIdKey()];
    if (deviceId && deviceId.length > 0) {
        return deviceId;
    } else {
        return @"unknown";
    }
}

- (NSString *)hnwStringForUserId {
    NSString *userId = [NSUserDefaults.hnwGroupUserDefaults stringForKey:HNWGroupUserDefaultsUserIdKey()];
    if (userId && userId.length > 0) {
        return userId;
    } else {
        return @"0";
    }
}

@end
