//
//  HNWCatchCrash.m
//  huinongwang
//
//  Created by yangyongzheng on 2017/12/20.
//  Copyright © 2017年 cnhnb. All rights reserved.
//

#import <execinfo.h>
#import "HNWCatchCrash.h"
#import "HNWStatisticsUtils.h"

// 记录上一个异常捕获handler的全局变量
static NSUncaughtExceptionHandler * beforeUncaughtExceptionHandler = NULL;
// crash回调block
static void(^ HNWPrivateCrashHandler)(NSString *crashCallStack) = nil;

@implementation HNWCatchCrash

#pragma mark - Public Method
#pragma mark 注册crash捕获
+ (void)registerUncaughtExceptionCrashHandler {
    // Backup before handler
    beforeUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    if (beforeUncaughtExceptionHandler == &HNWUncaughtExceptionHandler) {
        beforeUncaughtExceptionHandler = NULL;
    }
    // Set my handler
    NSSetUncaughtExceptionHandler(&HNWUncaughtExceptionHandler);
}

+ (void)setUncaughtExceptionCrashHandler:(void (^)(NSString *))crashHandler {
    if (crashHandler) {
        HNWPrivateCrashHandler = [crashHandler copy];
    }
}

#pragma mark - Private Method
#pragma mark exception crash回调
static void HNWUncaughtExceptionHandler(NSException *exception) {
    [HNWCatchCrash uncaughtExceptionCrashHandler:exception];
}

#pragma mark - crash处理
+ (void)uncaughtExceptionCrashHandler:(NSException *)exception {
    // 异常的堆栈信息、原因以及名称
    NSArray *stackSymbols = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"name：%@\n"
                               "reason：%@\n"
                               "callStack：%@\n\n"
                               "dSYM UUID: %@\n"
                               "CPU Type: %@\n"
                               "Address Slide: %@",
                               name,
                               reason,
                               stackSymbols,
                               HNWStatisticsUtils.DSYMUUID,
                               HNWStatisticsUtils.CPUType,
                               HNWStatisticsUtils.addressSlide];
    if (HNWPrivateCrashHandler) {
        HNWPrivateCrashHandler(exceptionInfo);
        HNWPrivateCrashHandler = nil;// 置空
    }
    
    // handler传递
    if (beforeUncaughtExceptionHandler != NULL) {
        beforeUncaughtExceptionHandler(exception);
    }
}

@end
