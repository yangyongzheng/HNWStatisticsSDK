//
//  HNWStatisticsRequest.h
//  huinongwang
//
//  Created by Young on 2020/3/24.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HNWStatisticsRequest : NSObject

/// 正常统计上报日志
/// @param uploadData 日志体
/// @param completion 结果回调
+ (void)requestUploadData:(NSData *)uploadData completion:(void (^)(NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
