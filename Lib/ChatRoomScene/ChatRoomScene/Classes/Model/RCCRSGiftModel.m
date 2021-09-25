//
//  RCCRSGiftModel.m
//  RCE
//
//  Created by shaoshuai on 2021/7/15.
//

#import "RCCRSGiftModel.h"

@implementation RCCRSGiftModel

- (instancetype)initWith:(NSString *)giftId name:(NSString *)name value:(NSUInteger)value count:(NSUInteger)count {
    if (self = [super init]) {
        _giftId = giftId;
        _name = name;
        _value = value;
        _count = count;
    }
    return self;
}

+ (NSDictionary *)encode:(RCCRSGiftModel *)gift {
    if (gift == nil) return @{};
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (gift.giftId) [dict setObject:gift.giftId forKey:@"id"];
    if (gift.name) [dict setObject:gift.name forKey:@"name"];
    [dict setObject:@(gift.value) forKey:@"value"];
    [dict setObject:@(gift.count) forKey:@"count"];
    return dict;
}

+ (RCCRSGiftModel *)decode:(NSDictionary *)info {
    NSUInteger value = [info[@"value"] integerValue];
    NSUInteger count = [info[@"count"] integerValue];
    return [[RCCRSGiftModel alloc] initWith:info[@"id"] name:info[@"name"] value:value count:count];
}

@end
