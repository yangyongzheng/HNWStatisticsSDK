//
//  HNWStatisticsUtils.m
//  huinongwang
//
//  Created by Young on 2020/3/23.
//  Copyright © 2020 cnhnb. All rights reserved.
//

#import "HNWStatisticsUtils.h"
#import <sys/utsname.h>
#include <mach/mach_host.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#import <zlib.h>

@interface NSData (HNWStatisticsUtils)
- (nullable NSData *)hnwGzipData;
@end

@implementation HNWStatisticsUtils

+ (NSString *)DSYMUUID {
    return HNWGetDSYMUUID().UUIDString;
}

+ (NSString *)addressSlide {
    return [NSString stringWithFormat:@"%ld", HNWGetImageVMAddressSlide()];
}

+ (NSString *)SIMOperator {
    NSString *operator = nil;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.0, *)) {
        NSDictionary *providers = [networkInfo serviceSubscriberCellularProviders];
        if (providers.count > 0) {
            NSArray<CTCarrier *> *allCarriers = providers.allValues;
            NSMutableArray *names = [NSMutableArray array];
            for (CTCarrier *carrier in allCarriers) {
                if (carrier.carrierName) {
                    [names addObject:carrier.carrierName];
                }
            }
            if (names.count > 0) {
                operator = [names componentsJoinedByString:@","];
            }
        }
    } else {
        CTCarrier *carrier = [networkInfo subscriberCellularProvider];
        operator = carrier.carrierName;
    }
    
    return operator;
}

+ (NSString *)screenSize {
    CGSize size = [UIScreen mainScreen].bounds.size;
    return [NSString stringWithFormat:@"%ldX%ld", lround(size.width), lround(size.height)];
}

+ (NSString *)platform {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (NSString *)CPUType {
    host_basic_info_data_t hostInfo;
    mach_msg_type_number_t infoCount = HOST_BASIC_INFO_COUNT;
    host_info(mach_host_self(), HOST_BASIC_INFO, (host_info_t)&hostInfo, &infoCount);
    
    NSString *cpuType = nil;
    if (hostInfo.cpu_type == CPU_TYPE_ANY) {
        cpuType = @"CPU_TYPE_ANY";
    } else if (hostInfo.cpu_type == CPU_TYPE_VAX) {
        cpuType = @"CPU_TYPE_VAX";
    } else if (hostInfo.cpu_type == CPU_TYPE_MC680x0) {
        cpuType = @"CPU_TYPE_MC680x0";
    } else if (hostInfo.cpu_type == CPU_TYPE_X86) {
        cpuType = @"CPU_TYPE_X86";
    } else if (hostInfo.cpu_type == CPU_TYPE_I386) {
        cpuType = @"CPU_TYPE_X86";
    } else if (hostInfo.cpu_type == CPU_TYPE_X86_64) {
        cpuType = @"CPU_TYPE_X86_64";
    } else if (hostInfo.cpu_type == CPU_TYPE_MC98000) {
        cpuType = @"CPU_TYPE_MC98000";
    } else if (hostInfo.cpu_type == CPU_TYPE_HPPA) {
        cpuType = @"CPU_TYPE_HPPA";
    } else if (hostInfo.cpu_type == CPU_TYPE_ARM) {
        cpuType = @"CPU_TYPE_ARM";
    } else if (hostInfo.cpu_type == CPU_TYPE_ARM64) {
        cpuType = @"CPU_TYPE_ARM64";
    } else if (hostInfo.cpu_type == CPU_TYPE_MC88000) {
        cpuType = @"CPU_TYPE_MC88000";
    } else if (hostInfo.cpu_type == CPU_TYPE_SPARC) {
        cpuType = @"CPU_TYPE_SPARC";
    } else if (hostInfo.cpu_type == CPU_TYPE_I860) {
        cpuType = @"CPU_TYPE_I860";
    } else if (hostInfo.cpu_type == CPU_TYPE_POWERPC) {
        cpuType = @"CPU_TYPE_POWERPC";
    } else if (hostInfo.cpu_type == CPU_TYPE_POWERPC64) {
        cpuType = @"CPU_TYPE_POWERPC64";
    } else {
        cpuType = [@"CPU_TYPE_" stringByAppendingString:[NSString stringWithFormat:@"%d", hostInfo.cpu_type]];
    }
    
    return cpuType;
}

+ (NSString *)deviceLanguage {
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray firstObject];
    return language;
}

+ (NSString *)currentTimestamp {
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    return [NSString stringWithFormat:@"%lld", llround(timestamp)];
}

+ (BOOL)isJailBreak {
    NSArray *jailbreakToolPathes = @[
        @"/Applications/Cydia.app",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/bin/bash",
        @"/usr/sbin/sshd",
        @"/etc/apt",
        @"/User/Applications/"
    ];
    // 方式1.判断是否存在越狱文件
    for (NSString *path in jailbreakToolPathes) {
        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            return YES;
        }
    }
    // 方式2.判断是否存在cydia应用
    if ([UIApplication.sharedApplication canOpenURL:[NSURL URLWithString:@"cydia://"]]){
        return YES;
    }
    // 方式3.读取环境变量
    char *env = getenv("DYLD_INSERT_LIBRARIES");
    if (env) {
        return YES;
    }
    
    return NO;
}

+ (NSData *)gzipDataWithJSONObject:(id)obj {
    if (obj && [NSJSONSerialization isValidJSONObject:obj]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:kNilOptions error:&error];
        if (!error && data) {
            return [data hnwGzipData];
        }
    }
    return nil;
}

+ (void)groupTask:(void (NS_NOESCAPE ^)(dispatch_group_t _Nonnull, NSString * _Nonnull))submit
       completion:(void (^)(NSString * _Nonnull))completion {
    dispatch_group_t group = dispatch_group_create();
    NSString *groupId = NSUUID.UUID.UUIDString;
    if (submit) {
        submit(group, groupId);
    }
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (completion) {
            completion(groupId);
        }
    });
}

#pragma mark 获取dSYM UUID
static NSUUID * HNWGetDSYMUUID(void) {
    const struct mach_header *executableHeader = NULL;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const struct mach_header *header = _dyld_get_image_header(i);
        if (header->filetype == MH_EXECUTE) {
            executableHeader = header;
            break;
        }
    }
    if (!executableHeader) {
        return nil;
    }
    
    BOOL is64bit = executableHeader->magic == MH_MAGIC_64 || executableHeader->magic == MH_CIGAM_64;
    uintptr_t cursor = (uintptr_t)executableHeader + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
    const struct segment_command *segmentCommand = NULL;
    for (uint32_t i = 0; i < executableHeader->ncmds; i++, cursor += segmentCommand->cmdsize) {
        segmentCommand = (struct segment_command *)cursor;
        if (segmentCommand->cmd == LC_UUID) {
            const struct uuid_command *uuidCommand = (const struct uuid_command *)segmentCommand;
            return [[NSUUID alloc] initWithUUIDBytes:uuidCommand->uuid];
        }
    }
    
    return nil;
}

static long HNWGetImageVMAddressSlide(void) {
    long slide = 0;
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        if (_dyld_get_image_header(i)->filetype == MH_EXECUTE) {
            slide = _dyld_get_image_vmaddr_slide(i);
            break;
        }
    }
    return slide;
}

@end



@implementation NSData (HNWStatisticsUtils)

- (NSData *)hnwGzipData {
    if (self.length == 0 || [self hnwIsGzippedData]) {
        return self;
    }
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)self.length;
    stream.next_in = (Bytef *)(void *)self.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    static const NSUInteger ChunkSize = 16384;
    
    NSMutableData *output = nil;
    if (deflateInit2(&stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        output = [NSMutableData dataWithLength:ChunkSize];
        while (stream.avail_out == 0) {
            if (stream.total_out >= output.length) {
                output.length += ChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    
    return output;
}

- (BOOL)hnwIsGzippedData {
    const UInt8 *bytes = (const UInt8 *)self.bytes;
    return (self.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

@end
