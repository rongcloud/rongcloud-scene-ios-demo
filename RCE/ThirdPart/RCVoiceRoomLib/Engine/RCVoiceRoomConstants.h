//
//  RCVoiceRoomConstants.h
//  RCE
//
//  Created by 叶孤城 on 2021/6/18.
//
#ifndef RCVoiceRoomConstants_h
#define RCVoiceRoomConstants_h

/// 房间信息key
FOUNDATION_EXPORT NSString * const RCRoomInfoKey;
/// 请求连麦
FOUNDATION_EXPORT NSString * const RCRequestSeatPrefixKey;

/// 排麦相关
FOUNDATION_EXPORT NSString * const RCRequestSeatContentRequest;
FOUNDATION_EXPORT NSString * const RCRequestSeatContentAccept;
FOUNDATION_EXPORT NSString * const RCRequestSeatContentCancelled;
FOUNDATION_EXPORT NSString * const RCRequestSeatContentDeny;

FOUNDATION_EXPORT NSString * const RCKickUserOutRoomContent;
FOUNDATION_EXPORT NSString * const RCPickerUserSeatContent;
FOUNDATION_EXPORT NSString * const RCAudienceJoinRoom;
FOUNDATION_EXPORT NSString * const RCAudienceLeaveRoom;
FOUNDATION_EXPORT NSString * const RCUserOnSeatSpeakingKey;
FOUNDATION_EXPORT NSString * const RCOnUserLeaveSeatEventPrefixKey;

FOUNDATION_EXPORT NSString * const RCSeatInfoSeatPartPrefixKey;
FOUNDATION_EXPORT NSString * const RCVoiceRoomPKInfoKey;

#endif /* RCVoiceRoomConstants_h */
