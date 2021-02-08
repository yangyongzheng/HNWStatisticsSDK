//
//  HNWStatisticsCrashLog.h
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsLogProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsCrashLog : NSObject <HNWStatisticsLogProvider>
@property (nonatomic, copy) NSString *time;         // 当前时间
@property (nonatomic, copy) NSString *sid;          // sessionId
@property (nonatomic, copy) NSString *pn;           // 当前页面id
@property (nonatomic, copy) NSString *stack;        // 错误栈信息
@property (nonatomic, copy) NSString *buildtime;    // ipa包build时间
@end

NS_ASSUME_NONNULL_END
