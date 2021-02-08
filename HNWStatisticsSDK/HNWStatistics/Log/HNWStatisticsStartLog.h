//
//  HNWStatisticsStartLog.h
//  HNWCore
//
//  Created by Young on 2020/3/21.
//  Copyright © 2020 Young. All rights reserved.
//

#import "HNWStatisticsLogProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsStartLog : NSObject <HNWStatisticsLogProvider>
@property (nonatomic) int64_t st;                   // 本次进入时间
@property (nonatomic) int64_t lst;                  // 上次进入时间
@property (nonatomic) int64_t let;                  // 上次退出时间
@property (nonatomic) NSInteger notify;             // 是否开启接收通知
@property (nonatomic, copy) NSString *sid;          // sessionId
@property (nonatomic, copy) NSString *longitude;    // 当前位置经度
@property (nonatomic, copy) NSString *latitude;     // 当前位置维度
@property (nonatomic, copy) NSString *location;     // 地区信息（省市区）
@property (nonatomic, copy) NSString *areaId;       // 省市区id，以`|`分割
@property (nonatomic, copy) NSString *network;      // 用户当前数据通讯方式0-无，1-WiFi，2-WWAN
@property (nonatomic, copy) NSString *getuiId;      // 个推clientId
@end

NS_ASSUME_NONNULL_END
