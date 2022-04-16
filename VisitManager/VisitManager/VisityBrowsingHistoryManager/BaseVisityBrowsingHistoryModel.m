//
//  BaseVisityBrowsingHistoryModel.m
//  AVPlayer
//
//  Created by 李鹏跃 on 2022/4/7.
//  Copyright © 2022 13lipengyue. All rights reserved.
//

#import "BaseVisityBrowsingHistoryModel.h"
#import <OBjc/runtime.h>


@implementation BaseVisityBrowsingHistoryModel
- (NSArray <NSString *>*)base_getCoderPropertys {
    return @[];
}
// MARK: - 归档

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [[self base_getCoderPropertys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = obj;
            if (key && [aDecoder decodeObjectForKey:key]) {
                [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
            }
        }];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [[self base_getCoderPropertys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        if (key) {
            [aCoder encodeObject:[self valueForKey:key] forKey:key];
        }
    }];
}

- (void)archiveDataWithFileName:(NSString *)fileName {
    if (![fileName isKindOfClass:[NSString class]] || !fileName.length) {
        return;
    }
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

+ (instancetype)unarchiveDataWithFileName:(NSString *)fileName {
    if (![fileName isKindOfClass:[NSString class]] || !fileName.length) {
        return nil;
    }
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:fileName];
    id model = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return model;
}

@end
