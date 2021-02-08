//
//  HNWStatisticsManager.m
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsManager.h"
#import "HNWStatisticsLogCache.h"
#import "HNWStatisticsUtils.h"
#import "HNWStatisticsRequest.h"
#import "HNWCatchCrash.h"
#import "HNWTimerHolder.h"
#import "HNWStatisticsDeviceLog.h"
#import "HNWStatisticsStartLog.h"
#import "HNWStatisticsPageLog.h"
#import "HNWStatisticsEventLog.h"
#import "HNWStatisticsCrashLog.h"

// 后台运行时间间隔，用来判断是否生成一个新sessionId，单位毫秒
static const long sessionTimeIntervalRefer  = 30 * 1000;
// NSUserDefaults Key
static NSString * const HNWSMStartupTimeKey = @"HNWSMStartupTimeKey";                   // 本次启动时间，value is NSString
static NSString * const HNWSMPreviousStartupTimeKey = @"HNWSMPreviousStartupTimeKey";   // 上次启动时间，value is NSString
static NSString * const HNWSMResignActiveTimeKey = @"HNWSMResignActiveTimeKey";         // 程序进入不活跃状态时间，value is NSString
static NSString * const HNWSMGeTuiClientIdKey = @"HNWSMGeTuiClientIdKey";               // 个推id，value is NSString
static NSString * const HNWSMAppVersionKey = @"HNWSMAppVersionKey";                     // AppVersion，value is NSString

@interface HNWStatisticsManager ()
@property (nonatomic, copy) NSString *currentSessionId;
@property (nonatomic, strong) HNWStatisticsConfiguration *configuration;
@property (nonatomic, strong) HNWTimerHolder *reportTimer;
@property (nonatomic, getter=isUploadingFlag) BOOL uploadingFlag;
@property (nonatomic, getter=isExistLogsWaitingUpload) BOOL existLogsWaitingUpload;
@property (nonatomic, getter=isServiceOpened) BOOL serviceOpened; // 是否已开启服务，控制数据上报（隐私政策授权后开启服务）
@property (nonatomic, strong) HNWStatisticsPageLog *lastPageLog;
@property (nonatomic, copy) NSString *lastPageName;
@end

@implementation HNWStatisticsManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self prepareEnvironment];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

#pragma mark - Public
+ (HNWStatisticsManager *)sharedManager {
    static HNWStatisticsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[HNWStatisticsManager alloc] init];
    });
    return manager;
}

+ (NSString *)currentSessionId {
    return HNWStatisticsManager.sharedManager.currentSessionId;
}

- (void)startWithConfiguration:(HNWStatisticsConfiguration *)configuration {
    [self updateConfiguration:configuration];
    // 更新App本次启动时间和上次启动时间
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *previousTimestamp = [userDefaults stringForKey:HNWSMStartupTimeKey];
    [userDefaults setObject:previousTimestamp forKey:HNWSMPreviousStartupTimeKey];
    [userDefaults setObject:HNWStatisticsUtils.currentTimestamp forKey:HNWSMStartupTimeKey];
    [userDefaults synchronize];
    // 保存本次冷启动日志
    [self saveStartLogCompletion:^(NSError *error) {}];
}

- (void)startService {
    // 启动服务上报日志
    self.serviceOpened = YES;
    [self checkBeforeRequestUploadAllLogs];
    // 冷启动上报设备信息
    if ([self reportDeviceInfoEnabled]) {
        [self requestUploadDeviceInfo];
    }
}

- (void)registerUncaughtExceptionCrashHandler {
    [HNWCatchCrash registerUncaughtExceptionCrashHandler];
    HNWWeakTransfer(self);
    [HNWCatchCrash setUncaughtExceptionCrashHandler:^(NSString *crashCallStack) {
        HNWStrongTransfer(self);
        [selfStrongRef uncaughtExceptionCrash:crashCallStack];
    }];
}

- (void)updateConfiguration:(HNWStatisticsConfiguration *)configuration {
    if (configuration && [configuration isKindOfClass:[HNWStatisticsConfiguration class]]) {
        @synchronized (self.configuration) {
            self.configuration.reportPolicy = configuration.reportPolicy;
            self.configuration.reportInterval = configuration.reportInterval;
            self.configuration.reportOnlyInWIFI = configuration.isReportOnlyInWIFI;
        }
        [self resetReportTimer];
    }
}

- (void)updateGeTuiClientId:(NSString *)clientId {
    if (HNWAssertStringNotEmpty(clientId)) {
        [NSUserDefaults.standardUserDefaults setObject:clientId forKey:HNWSMGeTuiClientIdKey];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

- (void)beginLogPageView:(NSString *)pageName {
    if (HNWAssertStringNotEmpty(pageName)) {
        int64_t currentTimestamp = HNWStatisticsUtils.currentTimestamp.longLongValue;
        HNWStatisticsPageLog *pageLog = [[HNWStatisticsPageLog alloc] init];
        pageLog.sid = self.currentSessionId;
        pageLog.st = currentTimestamp;
        pageLog.pn = pageName;
        pageLog.pf = HNWAssertStringNotEmpty(self.lastPageName) ? self.lastPageName : @"";
        [self endPageLogWithTimestamp:currentTimestamp];
        self.lastPageLog = pageLog;
        self.lastPageName = pageName;
    }
}

- (void)endPageLogWithTimestamp:(int64_t)endTimestamp {
    HNWStatisticsPageLog *pageLog = self.lastPageLog;
    if (pageLog && [pageLog isKindOfClass:[HNWStatisticsPageLog class]]) {
        pageLog.et = endTimestamp;
        pageLog.du = pageLog.et - pageLog.st;
        [HNWStatisticsLogCache saveLog:pageLog completion:^(NSError * _Nullable error) {
            if (!error) {
                self.existLogsWaitingUpload = YES;
            }
        }];
        self.lastPageLog = nil;
    }
}

- (void)event:(NSString *)eventId
    eventType:(HNWStatisticsEventType)eventType
        value:(NSString *)value
   attributes:(NSDictionary *)attributes {
    if (HNWAssertStringNotEmpty(eventId) && HNWAssertStringNotEmpty(value)) {
        HNWStatisticsEventLog *eventLog = [[HNWStatisticsEventLog alloc] init];
        eventLog.type = (int)eventType;
        eventLog.time = HNWStatisticsUtils.currentTimestamp.longLongValue;
        eventLog.sid = self.currentSessionId;
        eventLog.id = eventId;
        eventLog.value = value;
        eventLog.pn = [APPDELEGATE getCurrentPageName] ?: @"获取页面失败";
        if (attributes && [attributes isKindOfClass:[NSDictionary class]] && attributes.count > 0) {
            eventLog.kv = [NSArray arrayWithObject:[attributes copy]];
        } else {
            eventLog.kv = nil;
        }
        [HNWStatisticsLogCache saveLog:eventLog completion:^(NSError * _Nullable error) {
            if (!error) {
                self.existLogsWaitingUpload = YES;
            }
        }];
    }
}

- (void)pageRenderingDuration:(NSInteger)duration attributes:(NSDictionary *)attributes {
    if (duration >= 0) {
        HNWStatisticsEventLog *eventLog = [[HNWStatisticsEventLog alloc] init];
        NSString *currentTimestamp = HNWStatisticsUtils.currentTimestamp;
        eventLog.type = HNWStatisticsEventTypeCalculation;
        eventLog.time = [currentTimestamp longLongValue];
        eventLog.sid = self.currentSessionId;
        eventLog.pn = [APPDELEGATE getCurrentPageName] ?: @"获取页面失败";
        eventLog.id = [eventLog.pn stringByAppendingString:currentTimestamp];
        eventLog.value = [NSString stringWithFormat:@"%ld", (long)duration];
        if (attributes && [attributes isKindOfClass:[NSDictionary class]] && attributes.count > 0) {
            eventLog.kv = [NSArray arrayWithObject:[attributes copy]];
        } else {
            eventLog.kv = nil;
        }
        [HNWStatisticsLogCache saveLog:eventLog completion:^(NSError * _Nullable error) {
            if (!error) {
                self.existLogsWaitingUpload = YES;
            }
        }];
    }
}

- (void)manualReportingAllLogs:(void (^)(BOOL))completion {
    NSArray *logTypes = @[
        @(HNWStatisticsLogTypeStart),
        @(HNWStatisticsLogTypePage),
        @(HNWStatisticsLogTypeEvent),
        @(HNWStatisticsLogTypeCrash),
    ];
    [self fetchLogsWithTypes:logTypes completion:^(NSDictionary *data, NSArray<HNWStatisticsLogDeleteOptions *> *deleteOptions) {
        if (HNWAssertDictionaryNotEmpty(data)) {
            [HNWStatisticsRequest requestUploadLogs:data completion:^(NSError * _Nullable error) {
                if (!error) {
                    for (HNWStatisticsLogDeleteOptions *obj in deleteOptions) {
                        if (obj.logType == HNWStatisticsLogTypeCrash) {
                            [HNWStatisticsLogCache deleteLogsWithOptions:obj completion:^(NSError * _Nullable error) {}];
                            break;
                        }
                    }
                }
                if (completion) {
                    HNWDispatchSyncMainQueue(^{completion(!error);});
                }
            }];
        } else {
            if (completion) {
                HNWDispatchSyncMainQueue(^{completion(YES);});
            }
        }
    }];
}

#pragma mark - Private
#pragma mark 初始化配置
- (void)prepareEnvironment {
    // 初始化
    self.currentSessionId = [self sessionIdGenerator];
    self.configuration = HNWStatisticsConfiguration.defaultConfiguration;
    self.reportTimer = [[HNWTimerHolder alloc] init];
    self.existLogsWaitingUpload = YES;
    [self resetReportTimer];
    // 添加监听
    [self addNotifications];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminateNotification)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
}

#pragma mark 程序crash处理
- (void)uncaughtExceptionCrash:(NSString *)crashCallStack {
    [self updateAppResignActiveTime];
    [self endPageLogWithTimestamp:HNWStatisticsUtils.currentTimestamp.longLongValue];
    HNWStatisticsCrashLog *crashLog = [[HNWStatisticsCrashLog alloc] init];
    crashLog.time = HNWStatisticsUtils.currentTimestamp;
    crashLog.sid = self.currentSessionId;
    crashLog.pn = APPDELEGATE.getCurrentPageName ?: @"获取页面失败";
    crashLog.stack = crashCallStack;
    crashLog.buildtime = [DeviceUtils ipaBuildTime];
    [HNWStatisticsLogCache saveCrashLog:crashLog completion:^(NSError * _Nullable error) {}];
}

#pragma mark 前台进入后台(进入非活跃状态)
- (void)applicationDidEnterBackgroundNotification {
    [self updateAppResignActiveTime];
    [self endPageLogWithTimestamp:HNWStatisticsUtils.currentTimestamp.longLongValue];
    [self checkBeforeRequestUploadAllLogs];
}

#pragma mark 后台进入前台(进入活跃状态)
- (void)applicationWillEnterForegroundNotification {
    NSString *currentTimestamp = HNWStatisticsUtils.currentTimestamp;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *resignActiveTime = [userDefaults stringForKey:HNWSMResignActiveTimeKey];
    NSTimeInterval timeInterval =  [currentTimestamp longLongValue] - [resignActiveTime longLongValue];
    if (timeInterval >= sessionTimeIntervalRefer) {
        // 生成新session
        self.currentSessionId = [self sessionIdGenerator];
        NSString *previousTimestamp = [userDefaults stringForKey:HNWSMStartupTimeKey];
        [userDefaults setObject:previousTimestamp forKey:HNWSMPreviousStartupTimeKey];
        [userDefaults setObject:currentTimestamp forKey:HNWSMStartupTimeKey];
        [userDefaults synchronize];
        // 保存本次热启动日志并上报
        [self saveStartLogCompletion:^(NSError *error) {
            [self checkBeforeRequestUploadAllLogs];
        }];
    }
    // 生成新Page
    [self beginLogPageView:self.lastPageName];
}

#pragma mark 程序终止
- (void)applicationWillTerminateNotification {
    [self updateAppResignActiveTime];
}

#pragma mark 上报设备信息检查
- (BOOL)reportDeviceInfoEnabled {
    NSString *currentAppVersion = HNWAppVersion;
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    NSString *cacheAppVersion = [userDefaults stringForKey:HNWSMAppVersionKey];
    if (cacheAppVersion && [cacheAppVersion isEqualToString:currentAppVersion]) {
        return ![userDefaults boolForKey:HNWAReportedFirstLaunchInfoKey];
    } else {
        [userDefaults setBool:NO forKey:HNWAReportedFirstLaunchInfoKey];
        [userDefaults setObject:currentAppVersion forKey:HNWSMAppVersionKey];
        [userDefaults synchronize];
        return YES;
    }
}

- (BOOL)checkBeforeReporting {
    return (self.isServiceOpened &&
            self.isExistLogsWaitingUpload &&
            !self.isUploadingFlag &&
            (APPDELEGATE.currentNetworkStatus == ReachableViaWiFi || !self.configuration.isReportOnlyInWIFI));
}

#pragma mark 生成sessionId
- (NSString *)sessionIdGenerator {
    NSString *origin = [NSString stringWithFormat:@"iOS|%@|%@|%u", HNWStatisticsUtils.currentTimestamp, NSUUID.UUID.UUIDString, arc4random()];
    return [origin md5Encrypt];
}

- (NSString *)getuiClientId {
    NSString *clientId = nil;
    if (HNWAssertStringNotEmpty(APPDELEGATE.clientId)) {
        clientId = APPDELEGATE.clientId;
    } else {
        clientId = [NSUserDefaults.standardUserDefaults stringForKey:HNWSMGeTuiClientIdKey];
    }
    return HNWAssertStringNotEmpty(clientId) ? clientId : @"";
}

- (NSString *)networkState {
    if (APPDELEGATE.currentNetworkStatus == ReachableViaWiFi) {
        return @"WiFi";
    } else if (APPDELEGATE.currentNetworkStatus == ReachableViaWWAN) {
        return @"WWAN";
    } else {
        return @"未联网";
    }
}

+ (NSString *)rootKeyWithLogType:(HNWStatisticsLogType)logType {
    if (logType == HNWStatisticsLogTypeStart) {
        return @"start";
    } else if (logType == HNWStatisticsLogTypePage) {
        return @"page";
    } else if (logType == HNWStatisticsLogTypeEvent) {
        return @"event";
    } else if (logType == HNWStatisticsLogTypeCrash) {
        return @"crash";
    } else {
        return @"";
    }
}

- (void)getLongitude:(NSString **)longitude
            latitude:(NSString **)latitude
            location:(NSString **)location
              areaId:(NSString **)areaId {
    AreaInfo *areaInfo = HNWLocationManager.sharedLocationManager.areaInfo;
    if (!areaInfo.location) {
        areaInfo = HNWLocationManager.sharedLocationManager.lastAreaInfo;
    }
    if (areaInfo.location) {
        if (longitude) {
            *longitude = [NSString stringWithFormat:@"%f", areaInfo.location.coordinate.longitude];
        }
        if (latitude) {
            *latitude = [NSString stringWithFormat:@"%f", areaInfo.location.coordinate.latitude];
        }
        NSMutableString *fullAddress = [NSMutableString string];
        if (HNWAssertStringNotEmpty(areaInfo.province)) {
            [fullAddress appendString:areaInfo.province];
        }
        if (HNWAssertStringNotEmpty(areaInfo.city)) {
            [fullAddress appendString:areaInfo.city];
        }
        if (HNWAssertStringNotEmpty(areaInfo.district)) {
            [fullAddress appendString:areaInfo.district];
        }
        if (fullAddress.length > 0 && location) {
            *location = [fullAddress copy];
        }
        if (areaId) {
            *areaId = [NSString stringWithFormat:@"%ld|%ld|%ld", (long)areaInfo.provinceId, (long)areaInfo.cityId, (long)areaInfo.districtId];
        }
    } else {
        if (longitude) {*longitude = @"";}
        if (latitude) {*latitude = @"";}
        if (location) {*location = @"";}
        if (areaId) {*areaId = @"";}
    }
}

#pragma mark 更新定时器
- (void)resetReportTimer {
    NSTimeInterval interval = -1;
    if (self.configuration.reportPolicy == HNWStatisticsReportPolicyInterval) {
        interval = self.configuration.reportInterval;
    } else if (self.configuration.reportPolicy == HNWStatisticsReportPolicyRealTime) {
        interval = 1;
    }
    if (interval > 0) {
        HNWWeakTransfer(self);
        [self.reportTimer startTimerWithTimeInterval:interval repeats:YES block:^(HNWTimerHolder * _Nonnull timerHolder) {
            HNWStrongTransfer(self);
            [selfStrongRef checkBeforeRequestUploadAllLogs];
        }];
    } else {
        [self.reportTimer invalidateTimer];
    }
}

- (void)updateAppResignActiveTime {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:HNWStatisticsUtils.currentTimestamp forKey:HNWSMResignActiveTimeKey];
    [userDefaults synchronize];
}

- (void)fetchLogsWithTypes:(NSArray<NSNumber *> *)logTypes
                completion:(void (^)(NSDictionary *data, NSArray<HNWStatisticsLogDeleteOptions *> *deleteOptions))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSMutableArray *deleteOptions = [NSMutableArray array];
    [HNWStatisticsUtils groupTask:^(dispatch_group_t  _Nonnull group, NSString * _Nonnull groupId) {
        for (NSNumber *type in logTypes) {
            dispatch_group_enter(group);
            HNWStatisticsLogFetchOptions *fetchOptions = [HNWStatisticsLogFetchOptions optionsWithLogType:type.integerValue maximumCountLimit:5000];
            [HNWStatisticsLogCache fetchLogsWithOptions:fetchOptions completion:^(HNWStatisticsLogFetchResult * _Nonnull fetchResult) {
                if (!fetchResult.error && HNWAssertArrayNotEmpty(fetchResult.results)) {
                    NSString *rootKey = [HNWStatisticsManager rootKeyWithLogType:type.integerValue];
                    params[rootKey] = fetchResult.results;
                    HNWStatisticsLogDeleteOptions *opts = [HNWStatisticsLogDeleteOptions optionsWithLogType:type.integerValue
                                                                                                  minimumId:fetchResult.minimumId
                                                                                                  maximumId:fetchResult.maximumId];
                    if (opts) {
                        [deleteOptions addObject:opts];
                    }
                }
                dispatch_group_leave(group);
            }];
        }
    } completion:^(NSString * _Nonnull groupId) {
        if (completion) {
            completion([params copy], [deleteOptions copy]);
        }
    }];
}

- (void)checkBeforeRequestUploadAllLogs {
    if ([self checkBeforeReporting]) {
        self.uploadingFlag = YES;
        [self requestUploadAllLogsCompletion:^{
            self.uploadingFlag = NO;
        }];
    }
}

#pragma mark - get data
- (void)requestUploadDeviceInfo {
    HNWStatisticsDeviceLog *deviceLog = [[HNWStatisticsDeviceLog alloc] init];
    deviceLog.getuiId = [self getuiClientId];
    deviceLog.network = [self networkState];
    NSString *longitude, *latitude, *location;
    [self getLongitude:&longitude latitude:&latitude location:&location areaId:nil];
    deviceLog.longitude = longitude;
    deviceLog.latitude = latitude;
    deviceLog.location = location;
    NSDictionary *dictionary = [deviceLog modelToJSONDictionary];
    if (dictionary) {
        NSDictionary *reportDictionary = @{@"device" : dictionary};
        NSData *data = [HNWStatisticsUtils gzipDataWithJSONObject:reportDictionary];
        if (data) {
            [HNWStatisticsRequest requestUploadData:data completion:^(NSError * _Nullable error) {
                if (!error) {
                    [NSUserDefaults.standardUserDefaults setBool:YES forKey:HNWAReportedFirstLaunchInfoKey];
                    [NSUserDefaults.standardUserDefaults synchronize];
                }
            }];
        }
    }
}

- (void)requestUploadAllLogsCompletion:(void (^)(void))completion {
    NSArray *logTypes = @[
        @(HNWStatisticsLogTypeStart),
        @(HNWStatisticsLogTypePage),
        @(HNWStatisticsLogTypeEvent),
    ];
    [self fetchLogsWithTypes:logTypes completion:^(NSDictionary *data, NSArray<HNWStatisticsLogDeleteOptions *> *deleteOptions) {
        if (HNWAssertDictionaryNotEmpty(data)) {
            NSData *logData = [HNWStatisticsUtils gzipDataWithJSONObject:data];
            if (logData) {
                [HNWStatisticsRequest requestUploadData:logData completion:^(NSError * _Nullable error) {
                    if (!error) {
                        [HNWStatisticsUtils groupTask:^(dispatch_group_t  _Nonnull group, NSString * _Nonnull groupId) {
                            for (HNWStatisticsLogDeleteOptions *opts in deleteOptions) {
                                dispatch_group_enter(group);
                                [HNWStatisticsLogCache deleteLogsWithOptions:opts completion:^(NSError * _Nullable error) {
                                    dispatch_group_leave(group);
                                }];
                            }
                        } completion:^(NSString * _Nonnull groupId) {
                            if (completion) {completion();}
                        }];
                    } else {
                        if (completion) {completion();}
                    }
                }];
            } else {
                if (completion) {completion();}
            }
        } else {
            self.existLogsWaitingUpload = NO;
            if (completion) {completion();}
        }
    }];
}

#pragma mark - set data
- (void)saveStartLogCompletion:(void (^)(NSError *error))completion {
    NSString *st = [NSUserDefaults.standardUserDefaults stringForKey:HNWSMStartupTimeKey];
    NSString *lst = [NSUserDefaults.standardUserDefaults stringForKey:HNWSMPreviousStartupTimeKey];
    NSString *let = [NSUserDefaults.standardUserDefaults stringForKey:HNWSMResignActiveTimeKey];
    HNWStatisticsStartLog *startLog = [[HNWStatisticsStartLog alloc] init];
    startLog.st = HNWAssertStringNotEmpty(st) ? [st longLongValue] : 0;
    startLog.lst = HNWAssertStringNotEmpty(lst) ? [lst longLongValue] : 0;
    startLog.let = HNWAssertStringNotEmpty(let) ? [let longLongValue] : 0;
    startLog.sid = self.currentSessionId;
    startLog.network = [self networkState];
    startLog.getuiId = [self getuiClientId];
    NSString *longitude = @"";
    NSString *latitude = @"";
    NSString *location = @"";
    NSString *areaId = @"";
    [self getLongitude:&longitude latitude:&latitude location:&location areaId:&areaId];
    startLog.longitude = longitude;
    startLog.latitude = latitude;
    startLog.location = location;
    startLog.areaId = areaId;
    
    [HNWStatisticsLogCache saveLog:startLog completion:completion];
}

@end
