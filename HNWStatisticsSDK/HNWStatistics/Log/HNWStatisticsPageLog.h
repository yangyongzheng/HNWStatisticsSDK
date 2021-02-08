//
//  HNWStatisticsPageLog.h
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsLogProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsPageLog : NSObject <HNWStatisticsLogProvider>
@property (nonatomic, copy) NSString *sid;  // sessionId
@property (nonatomic) int64_t st;           // 开始时间
@property (nonatomic) int64_t et;           // 结束时间
@property (nonatomic) int64_t du;           // 持续时间
@property (nonatomic, copy) NSString *pf;   // 上一个页面id
@property (nonatomic, copy) NSString *pn;   // 当前页面id
@end

NS_ASSUME_NONNULL_END
