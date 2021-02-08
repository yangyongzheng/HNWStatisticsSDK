//
//  HNWStatisticsDeviceLog.h
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsDeviceLog : NSObject
@property (nonatomic, copy) NSString *channel;      // 渠道号
@property (nonatomic, copy) NSString *appVersion;   // 版本号
@property (nonatomic, copy) NSString *hnUserId;     // 惠农用户id
@property (nonatomic, copy) NSString *deviceId;     // 设备唯一标识

@property (nonatomic, copy) NSString *osType;       // 系统类型（1.Android，2.iOS）
@property (nonatomic, copy) NSString *operater;     // SIM1卡运营商
@property (nonatomic, copy) NSString *screen;       // 屏幕尺寸
@property (nonatomic, copy) NSString *model;        // 设备型号（机型）
@property (nonatomic, copy) NSString *chip;         // 硬件（芯片）
@property (nonatomic, copy) NSString *osVer;        // Android/iOS系统版本号
@property (nonatomic, copy) NSString *lang;         // 系统语言
@property (nonatomic, copy) NSString *rom;          // R0M总大小
@property (nonatomic) BOOL root;                    // 是否root/越狱
@property (nonatomic, copy) NSString *time;         // 当前时间
@property (nonatomic, copy) NSString *longitude;    // 当前位置经度
@property (nonatomic, copy) NSString *latitude;     // 当前位置维度
@property (nonatomic, copy) NSString *location;     // 地区信息（省市区）
@property (nonatomic, copy) NSString *network;      // 用户当前数据通讯方式0-无，1-WiFi，2-WWAN
@property (nonatomic, copy) NSString *getuiId;      // 个推clientId

- (nullable NSDictionary *)modelToJSONDictionary;
@end

NS_ASSUME_NONNULL_END
