//
//  RCVoiceRoomConfig.m
//  RCVoiceRoomEngine
//
//  Created by zang qilong on 2021/4/14.
//

#import "RCVoiceRoomInfo.h"

@interface RCVoiceRoomInfo()

@end

@implementation RCVoiceRoomInfo

- (instancetype)init {
    if (self = [super init]) {
        self.isFreeEnterSeat = false;
        self.isMuteAll = false;
        self.isLockAll = false;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    RCVoiceRoomInfo *copy = [[RCVoiceRoomInfo alloc] init];
    copy.extra = self.extra;
    copy.isFreeEnterSeat = self.isFreeEnterSeat;
    copy.isMuteAll = self.isMuteAll;
    copy.isLockAll = self.isLockAll;
    copy.seatCount = self.seatCount;
    copy.roomName = self.roomName;
    return copy;
}

- (NSString *)jsonString {
    NSMutableDictionary *dict = @{
        @"isFreeEnterSeat": @(self.isFreeEnterSeat),
        @"isMuteAll": @(self.isMuteAll),
        @"isLockAll": @(self.isLockAll),
        @"seatCount": @(self.seatCount),
        @"roomName": self.roomName
    }.mutableCopy;
    if (self.extra != nil) {
        dict[@"extra"] = self.extra;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (RCVoiceRoomInfo *)modelWithJSON:(NSString *)jsonSting {
    NSData *data = [jsonSting dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *roomName = dict[@"roomName"];
    NSNumber *seatCount = (NSNumber *)dict[@"seatCount"];
    NSNumber *isFreeEnterSeat = (NSNumber *)dict[@"isFreeEnterSeat"];
    NSNumber *isMuteAll = (NSNumber *)dict[@"isMuteAll"];
    NSNumber *isLockAll = (NSNumber *)dict[@"isLockAll"];
    NSString *extra = dict[@"extra"];
    if (roomName == nil || seatCount == nil) {
        return nil;
    }
    RCVoiceRoomInfo *info = [[RCVoiceRoomInfo alloc] init];
    info.roomName = roomName;
    info.seatCount = [seatCount integerValue];
    info.isFreeEnterSeat = (isFreeEnterSeat == nil ? NO : isFreeEnterSeat.boolValue);
    info.isMuteAll = (isMuteAll == nil ? NO : isMuteAll.boolValue);
    info.isLockAll = (isLockAll == nil ? NO : isLockAll.boolValue);
    info.extra = extra;
    return info;
}

- (NSDictionary *)createRoomKV {
    return @{@"key": @"RCRoomInfoKey",
             @"value" : [self jsonString]
    };
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[RCVoiceRoomInfo class]]) {
        return NO;
    }
    return [self isEqualToRoomInfo:(RCVoiceRoomInfo *)object];
}

- (BOOL)isEqualToRoomInfo:(RCVoiceRoomInfo *)info {
    if(!info) {
        return NO;
    }
    return (self.seatCount == info.seatCount)
    && [self.roomName isEqualToString:info.roomName]
    && [self.extra isEqualToString:info.extra]
    && (self.isFreeEnterSeat == info.isFreeEnterSeat);
}
@end
