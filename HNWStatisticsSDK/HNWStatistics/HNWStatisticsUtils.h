//
//  HNWStatisticsUtils.h
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsUtils : NSObject

@property (class, nonatomic, readonly) NSString *DSYMUUID;
@property (class, nonatomic, readonly) NSString *addressSlide;
@property (class, nonatomic, readonly) NSString *SIMOperator;
@property (class, nonatomic, readonly) NSString *screenSize;
@property (class, nonatomic, readonly) NSString *platform;
@property (class, nonatomic, readonly) NSString *CPUType;
@property (class, nonatomic, readonly) NSString *deviceLanguage;
@property (class, nonatomic, readonly) NSString *currentTimestamp; // 单位毫秒
@property (class, nonatomic, readonly) BOOL isJailBreak;

+ (nullable NSData *)gzipDataWithJSONObject:(id)obj;

+ (void)groupTask:(void (NS_NOESCAPE ^)(dispatch_group_t group, NSString *groupId))submit
       completion:(void (^)(NSString *groupId))completion;

@end

NS_ASSUME_NONNULL_END
