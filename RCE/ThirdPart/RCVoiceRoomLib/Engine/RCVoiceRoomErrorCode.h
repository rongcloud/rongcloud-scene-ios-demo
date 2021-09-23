//
//  RCVoiceRoomErrorCode.h
//  RCE
//
//  Created by 叶孤城 on 2021/5/26.
//

#ifndef RCVoiceRoomErrorCode_h
#define RCVoiceRoomErrorCode_h
typedef NS_ENUM(NSInteger, RCVoiceRoomErrorCode) {
    /// 操作成功
    RCVoiceRoomSuccess = 70000,
    /// 连接服务器失败
    RCVoiceRoomConnectTokenFailed,
    /// 麦位序号不对
    RCVoiceRoomSeatIndexOutOfRange,
    /// 用户已经在麦位上
    RCVoiceRoomUserAlreadyOnSeat,
    /// 用户不在麦位上
    RCVoiceRoomUserNotOnSeat,
    /// 用户跳麦的麦位和之前的一样
    RCVoiceRoomJumpIndexEqual,
    /// 麦位不是空置状态
    RCVoiceRoomSeatNotEmpty,
    /// 不能抱自己上麦
    RCVoiceRoomPickSelfToSeat,
    /// 发送抱麦请求失败
    RCVoiceRoomPickUserFailed,
    /// 不能踢自己下麦
    RCVoiceRoomUserKickSelfFromSeat,
    /// 加入语聊房失败
    RCVoiceRoomJoinRoomFailed,
    /// 离开语聊房失败
    RCVoiceRoomLeaveRoomFailed,
    /// 获取房间信息失败
    RCVoiceRoomGetRoomInfoFailed,
    /// 已经在排麦列表中了
    RCVoiceRoomAlreadyInRequestList,
    /// 排麦人数太多
    RCVoiceRoomRequestListFull,
    /// 排麦请求发送失败
    RCVoiceRoomSendRequestSeatFailed,
    /// 取消排麦请求发送失败
    RCVoiceRoomCancelRequestSeatFailed,
    /// 同意排麦请求发送失败
    RCVoiceRoomAcceptRequestSeatFailed,
    /// 拒绝排麦请求发送失败
    RCVoiceRoomRejectRequestSeatFailed,
    /// 同步麦位信息失败
    RCVoiceRoomSyncSeatInfoFailed,
    /// 同步房间信息失败
    RCVoiceRoomSyncRoomInfoFailed,
    /// 同步排麦相关信息
    RCVoiceRoomSyncRequestSeatFailed,
    /// 获取排麦请求列表失败
    RCVoiceRoomGetRequestListFailed,
    /// 发送信息失败
    RCVoiceRoomSendMessageFailed,
    /// 请求发送失败
    RCVoiceRoomSendInvitationSeatFailed,
    /// 取消请求发送失败
    RCVoiceRoomCancelInvitationFailed,
    /// 同意请求发送失败
    RCVoiceRoomAcceptInvitationFailed,
    /// 拒绝请求发送失败
    RCVoiceRoomRejectInvitationFailed,
    /// 创建语聊房失败
    RCVoiceRoomCreateRoomFailed,
    /// 用户ID为空
    RCVoiceRoomUserIdIsEmpty,
    /// 获取麦位信息失败
    RCVoiceRoomGetLatestSeatInfoFailed,
    /// 开始PK失败
    RCVoiceRoomBeginPKFailed,
    /// 退出PK失败
    RCVoiceRoomQuitPKFailed,
    /// 发送PK邀请失败
    RCVoiceRoomSendPKInviteFaild,
    /// 取消PK请求失败
    RCVoiceRoomCancelPKFailed
};

#endif /* RCVoiceRoomErrorCode_h */
