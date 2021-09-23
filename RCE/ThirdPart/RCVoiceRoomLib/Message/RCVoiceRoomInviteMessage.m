//
//  RCInviteMessage.m
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

#import "RCVoiceRoomInviteMessage.h"

@implementation RCVoiceRoomInviteMessage

- (id)initWithInvitationId:(NSString *)invitationId
                senderUser:(NSString *)senderId
                  targetId:(NSString *)targetId
                       type:(RCVoiceRoomInviteType)type
                   content:(NSString *)content {
    if (self = [super init]) {
        self.invitationId = invitationId;
        self.sendUserId = senderId;
        self.targetId = targetId;
        self.type = type;
        self.content = content;
    }
    return self;
}

- (NSData *)encode {
    NSMutableDictionary *dict = @{
        @"sendUserId": self.sendUserId,
        @"type": @(self.type),
        @"invitationId": self.invitationId
    }.mutableCopy;
    if (self.targetId != nil) {
        dict[@"targetId"] = self.targetId;
    }
    if (self.content != nil) {
        dict[@"content"] = self.content;
    }
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.invitationId = dict[@"invitationId"];
    self.sendUserId = dict[@"sendUserId"];
    self.type = [dict[@"type"] unsignedIntValue];
    self.content = dict[@"content"];
    self.targetId = dict[@"targetId"];
}

+ (NSString *)getObjectName {
    return @"RC:VRLInviteMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end
