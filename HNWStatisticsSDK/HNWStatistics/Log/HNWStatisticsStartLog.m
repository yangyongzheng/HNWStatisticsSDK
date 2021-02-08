//
//  HNWStatisticsStartLog.m
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsStartLog.h"

@implementation HNWStatisticsStartLog

@synthesize appVersion = _appVersion;
@synthesize channel = _channel;
@synthesize deviceId = _deviceId;
@synthesize hnUserId = _hnUserId;

- (HNWStatisticsLogType)logType {
    return HNWStatisticsLogTypeStart;
}

- (NSDictionary *)JSONDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"channel"] = self.channel;
    dict[@"appVersion"] = self.appVersion;
    dict[@"hnUserId"] = self.hnUserId;
    dict[@"deviceId"] = self.deviceId;
    dict[@"st"] = [NSNumber numberWithLongLong:self.st];
    dict[@"lst"] = [NSNumber numberWithLongLong:self.lst];
    dict[@"let"] = [NSNumber numberWithLongLong:self.let];
    dict[@"notify"] = [NSNumber numberWithInteger:self.notify];
    dict[@"sid"] = self.sid;
    dict[@"longitude"] = self.longitude;
    dict[@"latitude"] = self.latitude;
    dict[@"location"] = self.location;
    dict[@"areaId"] = self.areaId;
    dict[@"network"] = self.network;
    dict[@"getuiId"] = self.getuiId;
    return dict.count > 0 ? [dict copy] : nil;
}

- (instancetype)init {
    if (self = [super init]) {
        self.appVersion = HNWAppVersion;
        self.channel = @"AppStore";
        HNWDispatchSyncMainQueue(^{
            self.hnUserId = [NSString stringWithFormat:@"%ld", APPDELEGATE.loginInfo.user.hnUserId];
            self.deviceId = APPDELEGATE.identity;
            self.notify = [SystemSettingsManager isOpenedNotification];
        });
    }
    return self;
}

@end
