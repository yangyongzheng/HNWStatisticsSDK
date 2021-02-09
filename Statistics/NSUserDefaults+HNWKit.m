//
//  NSUserDefaults+HNWKit.m
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import "NSUserDefaults+HNWKit.h"

NSString * const HNWUserDefaultsKey(NSString *key) {
    if (key && [key isKindOfClass:[NSString class]] && key.length > 0) {
        return [NSString stringWithFormat:@"%@.%@", [NSBundle mainBundle].bundleIdentifier, key];
    } else {
        return @"";
    }
}

@implementation NSUserDefaults (HNWKit)

+ (NSUserDefaults *)hnwSharedUserDefaults {
    static NSUserDefaults *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *groupId = [NSString stringWithFormat:@"group.%@", [NSBundle mainBundle].bundleIdentifier];
        sharedInstance = [[NSUserDefaults alloc] initWithSuiteName:groupId];
    });
    return sharedInstance;
}

@end
