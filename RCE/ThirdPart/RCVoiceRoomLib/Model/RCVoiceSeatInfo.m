//
//  RCSeatInfo.m
//  RCVoiceRoomEngine
//
//  Created by zang qilong on 2021/4/14.
//

#import "RCVoiceSeatInfo.h"

@interface RCVoiceSeatInfo ()


@end

@implementation RCVoiceSeatInfo

- (instancetype)init {
    if (self = [super init]) {
        self.status = RCSeatStatusEmpty;
        self.mute = NO;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    RCVoiceSeatInfo *copy = [[RCVoiceSeatInfo alloc] init];
    copy.status = self.status;
    copy.mute = self.isMuted;
    copy.userId = self.userId;
    copy.extra = self.extra;
    return copy;
}

- (NSString *)jsonString {
    NSMutableDictionary *dict = @{
        @"status": @(self.status),
        @"mute": @(self.isMuted)
    }.mutableCopy;
    if (self.extra != nil) {
        dict[@"extra"] = self.extra;
    }
    if (self.userId != nil) {
        dict[@"userId"] = self.userId;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (RCVoiceSeatInfo *)modelWithJSON:(NSString *)jsonSting {
    NSData *data = [jsonSting dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *extra = dict[@"extra"];
    NSNumber *isMuted = (NSNumber *)dict[@"mute"];
    NSNumber *status = (NSNumber *)dict[@"status"];
    NSString *userId = dict[@"userId"];
    if (status == nil) {
        return nil;
    }
    RCVoiceSeatInfo *info = [[RCVoiceSeatInfo alloc] init];
    info.userId = userId;
    info.extra = extra;
    info.mute = (isMuted == nil ? NO : isMuted.boolValue);
    info.status = (status == nil ? NO : status.integerValue);
    return info;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"status is %lu, userId is %@, isMute is %d",
            (unsigned long)self.status,
            self.userId,
            self.isMuted];
}

@end
