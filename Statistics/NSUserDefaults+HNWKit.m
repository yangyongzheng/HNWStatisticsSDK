//
//  NSUserDefaults+HNWKit.m
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import "NSUserDefaults+HNWKit.h"

static NSString * const HNWUserDefaultsDefaultGroup() {
    return [NSString stringWithFormat:@"group.%@", [NSBundle mainBundle].bundleIdentifier];
}



NSString * const HNWGroupUserDefaultsDeviceIdKey() {
    return [NSString stringWithFormat:@"%@.%@", HNWUserDefaultsDefaultGroup(), @"deviceId"];
}

NSString * const HNWGroupUserDefaultsUserIdKey() {
    return [NSString stringWithFormat:@"%@.%@", HNWUserDefaultsDefaultGroup(), @"userId"];
}


NSString * const HNWGroupUserDefaultsKey(NSString *key) {
    if (key && [key isKindOfClass:[NSString class]] && key.length > 0) {
        return [NSString stringWithFormat:@"%@.%@", HNWUserDefaultsDefaultGroup(), key];
    } else {
        return @"";
    }
}



@implementation NSUserDefaults (HNWKit)

+ (NSUserDefaults *)hnwGroupUserDefaults {
    static NSUserDefaults *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NSUserDefaults alloc] initWithSuiteName:HNWUserDefaultsDefaultGroup()];
    });
    return sharedInstance;
}

@end
