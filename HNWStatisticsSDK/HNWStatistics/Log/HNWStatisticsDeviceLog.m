//
//  HNWStatisticsDeviceLog.m
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsDeviceLog.h"
#import "HNWStatisticsUtils.h"

@implementation HNWStatisticsDeviceLog

- (instancetype)init {
    self = [super init];
    if (self) {
        self.channel = @"AppStore";
        self.appVersion = HNWAppVersion;
        HNWDispatchSyncMainQueue(^{
            self.hnUserId = [NSString stringWithFormat:@"%ld", APPDELEGATE.loginInfo.user.hnUserId];
            self.deviceId = APPDELEGATE.identity;
        });
        self.osType = @"iOS";
        self.operater = HNWStatisticsUtils.SIMOperator ?: @"无";
        self.screen = HNWStatisticsUtils.screenSize;
        self.model = HNWStatisticsUtils.platform;
        self.chip = HNWStatisticsUtils.CPUType;
        self.osVer = [[UIDevice currentDevice] systemVersion];
        self.lang = [HNWStatisticsUtils deviceLanguage] ?: @"zh-Hans";
        self.rom = [DeviceUtils stringFromFileOrStorageFormatByteCount:[DeviceUtils getDiskTotalSpace]];
        self.root = HNWStatisticsUtils.isJailBreak;
        self.time = HNWStatisticsUtils.currentTimestamp;
    }
    
    return self;
}

- (NSDictionary *)modelToJSONDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"channel"] = self.channel;
    dict[@"appVersion"] = self.appVersion;
    dict[@"hnUserId"] = self.hnUserId;
    dict[@"deviceId"] = self.deviceId;
    dict[@"osType"] = self.osType;
    dict[@"operater"] = self.operater;
    dict[@"screen"] = self.screen;
    dict[@"model"] = self.model;
    dict[@"chip"] = self.chip;
    dict[@"osVer"] = self.osVer;
    dict[@"lang"] = self.lang;
    dict[@"rom"] = self.rom;
    dict[@"root"] = [NSNumber numberWithBool:self.root];
    dict[@"time"] = self.time;
    dict[@"longitude"] = self.longitude;
    dict[@"latitude"] = self.latitude;
    dict[@"location"] = self.location;
    dict[@"network"] = self.network;
    dict[@"getuiId"] = self.getuiId;
    return dict.count > 0 ? [dict copy] : nil;
}

@end
