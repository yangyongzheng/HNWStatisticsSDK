//
//  NSUserDefaults+HNWKit.h
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const HNWUserDefaultsKey(NSString *key);

@interface NSUserDefaults (HNWKit)

@property (class, readonly, strong) NSUserDefaults *hnwSharedUserDefaults;

@end

NS_ASSUME_NONNULL_END
