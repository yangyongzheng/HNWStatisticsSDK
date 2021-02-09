//
//  HNWStatisticsBasicInfo.m
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import "HNWStatisticsBasicInfo.h"
#import "NSUserDefaults+HNWKit.h"

@implementation HNWStatisticsBasicInfo

+ (HNWStatisticsBasicInfo *)sharedBasicInfo {
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
        _hnwUserId = @"0";
        _hnwAppVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleShortVersionString"];
        _hnwChannel = @"App Store";
    }
    return self;
}

- (NSString *)hnwDeviceId {
    NSString *deviceId = [NSUserDefaults.hnwSharedUserDefaults stringForKey:HNWUserDefaultsKey(@"deviceId")];
    if (deviceId && deviceId.length > 0) {
        return deviceId;
    } else {
        return @"unknown";
    }
}

- (void)setHnwUserId:(NSString *)hnwUserId {
    if (hnwUserId && [hnwUserId isKindOfClass:[NSString class]] && hnwUserId.length > 0) {
        _hnwUserId = [hnwUserId copy];
    } else {
        _hnwUserId = @"0";
    }
}

@end
