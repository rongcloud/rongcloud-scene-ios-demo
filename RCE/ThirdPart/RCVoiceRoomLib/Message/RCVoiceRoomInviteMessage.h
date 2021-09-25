//
//  RCInviteMessage.h
//  RCE
//
//  Created by 叶孤城 on 2021/4/20.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RCVoiceRoomInviteType) {
    RCVoiceRoomInviteTypeRequest = 0,
    RCVoiceRoomInviteTypeAccept = 1,
    RCVoiceRoomInviteTypeReject = 2,
    RCVoiceRoomInviteTypeCancel = 3
};

@interface RCVoiceRoomInviteMessage : RCMessageContent

@property (nonatomic, copy, nonnull) NSString *invitationId;
@property (nonatomic, copy, nonnull) NSString *sendUserId;
@property (nonatomic, copy, nullable) NSString *targetId;
@property (nonatomic, assign) RCVoiceRoomInviteType type;
@property (nonatomic, copy, nullable) NSString *content;

- (id)initWithInvitationId:(NSString *)invitationId
                senderUser:(NSString *)senderId
                  targetId:(NSString *)targetId
                       type:(RCVoiceRoomInviteType)type
                   content:(NSString *)content;
@end

NS_ASSUME_NONNULL_END
