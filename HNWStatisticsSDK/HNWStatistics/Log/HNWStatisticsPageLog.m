//
//  HNWStatisticsPageLog.m
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsPageLog.h"

@implementation HNWStatisticsPageLog

@synthesize appVersion = _appVersion;
@synthesize channel = _channel;
@synthesize deviceId = _deviceId;
@synthesize hnUserId = _hnUserId;

- (HNWStatisticsLogType)logType {
    return HNWStatisticsLogTypePage;
}

- (NSDictionary *)JSONDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"channel"] = self.channel;
    dict[@"appVersion"] = self.appVersion;
    dict[@"hnUserId"] = self.hnUserId;
    dict[@"deviceId"] = self.deviceId;
    dict[@"sid"] = self.sid;
    dict[@"st"] = [NSNumber numberWithLongLong:self.st];
    dict[@"et"] = [NSNumber numberWithLongLong:self.et];
    dict[@"du"] = [NSNumber numberWithLongLong:self.du];
    dict[@"pf"] = self.pf;
    dict[@"pn"] = self.pn;
    return dict.count > 0 ? [dict copy] : nil;
}

- (instancetype)init {
    if (self = [super init]) {
        self.appVersion = HNWAppVersion;
        self.channel = @"AppStore";
        HNWDispatchSyncMainQueue(^{
            self.hnUserId = [NSString stringWithFormat:@"%ld", APPDELEGATE.loginInfo.user.hnUserId];
            self.deviceId = APPDELEGATE.identity;
        });
    }
    return self;
}

@end
