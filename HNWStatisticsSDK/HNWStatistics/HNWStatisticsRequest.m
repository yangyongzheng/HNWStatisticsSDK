//
//  HNWStatisticsRequest.m
//  huinongwang
//
//  Created by Young on 2020/3/24.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsRequest.h"

#ifdef DEBUG
static NSString * const HNWStatisticsRequestServer = @"http://gather.cnhnkj.cn/";
#else
static NSString * const HNWStatisticsRequestServer = @"http://gather.cnhnb.com/";
#endif

@implementation HNWStatisticsRequest

#pragma mark - App统计数据上报地址
+ (NSString *)uploadStatisticsDataAddress {
    return [HNWStatisticsRequestServer stringByAppendingPathComponent:@"peach/userlog/write/log/file/app"];
}

#pragma mark - request
+ (void)requestUploadData:(NSData *)uploadData completion:(void (^)(NSError * _Nullable))completion {
    if (uploadData && [uploadData isKindOfClass:[NSData class]] && uploadData.length > 0) {
        NSURLSession *sharedSession = [NSURLSession sharedSession];
        NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:HNWStatisticsRequest.uploadStatisticsDataAddress]];
        mutableRequest.HTTPMethod = @"POST";
        mutableRequest.timeoutInterval = 20;
        mutableRequest.HTTPShouldHandleCookies = NO; // 不写入cookies
        [mutableRequest setValue:[NSString stringWithFormat:@"%lld", (int64_t)uploadData.length]
              forHTTPHeaderField:@"Content-Length"];
        [mutableRequest setValue:@"gzip"
              forHTTPHeaderField:@"Content-Encoding"];
        [mutableRequest setValue:@"AppStore"
              forHTTPHeaderField:@"channel"];
        [mutableRequest setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
              forHTTPHeaderField:@"appVersion"];
        [mutableRequest setValue:[NSString stringWithFormat:@"%ld", 0]
              forHTTPHeaderField:@"hnUserId"];
        [mutableRequest setValue:NSUUID.UUID.UUIDString
              forHTTPHeaderField:@"deviceId"];
        [[sharedSession uploadTaskWithRequest:mutableRequest fromData:uploadData completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            HNWDispatchSyncMainQueue(^{
                if (completion) {
                    if (!error) {
                        NSError *tempError = nil;
                        NSDictionary *tempDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                        if (HNWAssertDictionaryNotEmpty(tempDictionary)) {
                            DataProtocolTemplate *template = [DataProtocolTemplate yy_modelWithDictionary:tempDictionary];
                            if (template && template.errorCode) {
                                tempError = [NSError errorWithDomain:template.message code:template.errorCode userInfo:nil];
                            }
                        }
                        
                        completion(tempError);
                    } else {
                        completion(error);
                    }
                }
            });
        }] resume];
    } else {
        if (completion) {
            HNWDispatchSyncMainQueue(^{
                completion([NSError errorWithDomain:@"一个或多个入参无效" code:NSURLErrorResourceUnavailable userInfo:nil]);
            });
        }
    }
}

@end
