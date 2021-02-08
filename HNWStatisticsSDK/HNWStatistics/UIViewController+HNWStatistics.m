//
//  UIViewController+HNWStatistics.m
//  HNWStatisticsSDK
//
//  Created by Young on 2021/2/8.
//

#import "UIViewController+HNWStatistics.h"
#import "HNWStatisticsSDK.h"
#import <objc/runtime.h>

@implementation UIViewController (HNWStatistics)

- (BOOL)hnwIsRequiredStatistics {
    return NO;
}

+ (void)load {
    if (self == [UIViewController class]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Method originalMethod = class_getInstanceMethod(self, @selector(viewDidAppear:));
            Method swizzledMethod = class_getInstanceMethod(self, @selector(hnwStatisticsViewDidAppear:));
            method_exchangeImplementations(originalMethod, swizzledMethod);
        });
    }
}

- (void)hnwStatisticsViewDidAppear:(BOOL)animated {
    [self hnwStatisticsViewDidAppear:animated];
    if ([[self hnwViewControllerWhitelist] containsObject:NSStringFromClass([self class])] ||
        ([self hnwIsRequiredStatistics] && ![self hnwStatisticsIsMZFormSheetScene])) {
        [HNWStatisticsSDK beginLogPageView:NSStringFromClass([self class])];
    }
}

- (BOOL)hnwStatisticsIsMZFormSheetScene {
    Class theClass = NSClassFromString(@"MZFormSheetWindow");
    return (theClass && [self.view.window isMemberOfClass:theClass]);
}

- (NSArray<NSString *> *)hnwViewControllerWhitelist {
    static NSArray *whitelist = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        whitelist = @[
            @"JVTelecomViewController",
            @"JVWebViewController",
            @"XHLaunchAdController",
        ];
    });
    return whitelist;
}

@end
