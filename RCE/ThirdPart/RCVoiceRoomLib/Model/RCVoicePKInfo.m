//
//  RCVoicePKInfo.m
//  RCE
//
//  Created by 叶孤城 on 2021/8/17.
//

#import "RCVoicePKInfo.h"

@implementation RCVoicePKInfo

- (instancetype)initWithInviterId:(NSString *)inviterUserId
                    inviterRoomId:(NSString *)inviterRoomId
                        inviteeId:(NSString *)inviteeUserId
                    inviteeRoomId:(NSString *)inviteeRoomId {
    if (self = [super init]) {
        self.inviterUserId = inviterUserId;
        self.inviterRoomId = inviterRoomId;
        self.inviteeUserId = inviteeUserId;
        self.inviteeRoomId = inviteeRoomId;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    RCVoicePKInfo *copy = [[RCVoicePKInfo alloc] init];
    copy.inviterUserId = self.inviterUserId;
    copy.inviterRoomId = self.inviterRoomId;
    copy.inviteeUserId = self.inviteeUserId;
    copy.inviteeRoomId = self.inviteeRoomId;
    return copy;
}

- (NSString *)jsonString {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.inviterUserId != nil) {
        dict[@"inviterUserId"] = self.inviterUserId;
    }
    if (self.inviterRoomId != nil) {
        dict[@"inviterRoomId"] = self.inviterRoomId;
    }
    if (self.inviteeUserId != nil) {
        dict[@"inviteeUserId"] = self.inviteeUserId;
    }
    if (self.inviteeRoomId != nil) {
        dict[@"inviteeRoomId"] = self.inviteeRoomId;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (RCVoicePKInfo *)modelWithJSON:(NSString *)jsonSting {
    NSData *data = [jsonSting dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    RCVoicePKInfo *info = [[RCVoicePKInfo alloc] init];
    info.inviterUserId = dict[@"inviterUserId"];
    info.inviterRoomId = dict[@"inviterRoomId"];
    info.inviteeUserId = dict[@"inviteeUserId"];
    info.inviteeRoomId = dict[@"inviteeRoomId"];
    return info;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"inviterUserId is %@, inviterRoomId is %@", self.inviterUserId, self.inviterRoomId];
}

@end
