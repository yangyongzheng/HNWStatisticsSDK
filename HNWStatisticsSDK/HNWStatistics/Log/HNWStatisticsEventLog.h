//
//  HNWStatisticsEventLog.h
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsLogProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsEventLog : NSObject <HNWStatisticsLogProvider>
@property (nonatomic) int type;                                     // 1、计数,2、计算,3、属性
@property (nonatomic) int64_t time;                                 // 时间
@property (nonatomic, copy) NSString *sid;                          // sessionId
@property (nonatomic, copy) NSString *id;                           // 事件id
@property (nonatomic, copy) NSString *value;                        // 数值（计数时为次数，计算时为数量，属性为属性值）
@property (nonatomic, copy) NSString *pn;                           // 所属页面
@property (nullable, nonatomic, copy) NSArray<NSDictionary *> *kv;  // 附带参数（可以为空）
@end

NS_ASSUME_NONNULL_END
