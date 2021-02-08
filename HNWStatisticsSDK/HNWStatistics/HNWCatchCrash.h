//
//  HNWCatchCrash.h
//  huinongwang
//
//  Created by yangyongzheng on 2017/12/20.
//  Copyright © 2017年 cnhnb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HNWCatchCrash : NSObject

+ (void)setUncaughtExceptionCrashHandler:(void(^)(NSString *crashCallStack))crashHandler;
+ (void)registerUncaughtExceptionCrashHandler;

@end
