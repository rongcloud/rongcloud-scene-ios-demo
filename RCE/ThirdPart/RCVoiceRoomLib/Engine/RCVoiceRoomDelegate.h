//
//  RCVoiceRoomDelegate.h
//  RCVoiceRoomEngine
//
//  Created by zang qilong on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import "RCVoiceRoomInfo.h"
#import "RCVoiceSeatInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class RCMessage;

@protocol RCVoiceRoomDelegate <NSObject>

//@optional

/// 房间的信息和麦位信息初始化完成回调，用户可在此执行关于房间的其他初始化操作
- (void)roomKVDidReady;

/// 房间发生异常问题
- (void)roomDidOccurError:(RCVoiceRoomErrorCode)code;

/// 房间信息变更回调
/// 第一次加入房间时也会触发回调
/// @param roomInfo 房间信息
- (void)roomInfoDidUpdate:(RCVoiceRoomInfo *)roomInfo;

/// 房间座位变更回调，包括自身上麦或下麦也会触发此回调
/// @param seatInfolist 座位列表信息
- (void)seatInfoDidUpdate:(NSArray<RCVoiceSeatInfo *> *)seatInfolist;

/// 某个主播上麦回调，包含自己上麦也会触发此回调
/// @param seatIndex 麦位号
/// @param userId 用户Id
- (void)userDidEnterSeat:(NSInteger)seatIndex
                   user:(NSString *)userId;

/// 某个主播下麦回调，包含自己下麦也会触发此回调
/// @param seatIndex 麦位号
/// @param userId 用户Id
- (void)userDidLeaveSeat:(NSInteger)seatIndex
                   user:(NSString *)userId;

/// 座位静音状态回调
/// @param index 座位号
/// @param isMute 静音状态
- (void)seatDidMute:(NSInteger)index
            isMute:(BOOL)isMute;

/// 座位关闭回调
/// @param index 座位号
/// @param isLock 是否关闭
- (void)seatDidLock:(NSInteger)index
            isLock:(BOOL)isLock;

/// 观众进房回调
/// @param userId 观众Id
- (void)userDidEnter:(NSString *)userId;

/// 观众退房回调
/// @param userId 观众Id
- (void)userDidExit:(NSString *)userId;

/// 用户麦克风状态变化回调
/// @param seatIndex 麦位序号
/// @param isSpeaking 是否正在说话
- (void)speakingStateDidChange:(NSUInteger)seatIndex
                                  speakingState:(BOOL)isSpeaking;

/// 收取信息回调
/// @param message 收到的消息
- (void)messageDidReceive:(RCMessage *)message;


/// 收到房间通知
/// @param name 通知的名臣
/// @param content 通知的内容
- (void)roomNotificationDidReceive:(NSString *)name
                           content:(NSString *)content;

/// 收到自己被抱上麦的请求
- (void)pickSeatDidReceiveBy:(NSString *)userId;

/// 收到自己被下麦的通知
- (void)kickSeatDidReceive:(NSUInteger)seatIndex;

/// 发送的排麦请求得到房主或管理员同意
- (void)requestSeatDidAccept;

/// 发送的排麦请求被房主或管理员拒绝
- (void)requestSeatDidReject;

/// 排麦列表发生变化
- (void)requestSeatListDidChange;

/// 接受邀请
/// @param invitationId 邀请的Id
/// @param userId 发送邀请的用户
/// @param content 邀请内容，用户可以自定义
- (void)invitationDidReceive:(NSString *)invitationId
                          from:(NSString *)userId
                       content:(NSString *)content;

/// 邀请被接受回调
/// @param invitationId 邀请Id
- (void)invitationDidAccept:(NSString *)invitationId;

/// 邀请被拒绝回调
/// @param invitationId 邀请Id
- (void)invitationDidReject:(NSString *)invitationId;

/// 邀请被取消回调
/// @param invitationId 邀请Id
- (void)invitationDidCancel:(NSString *)invitationId;

/// 用户被踢出房间的回调
/// @param targetId 被踢出房间的用户id
/// @param userId 执行踢某人出房间的用户id
- (void)userDidKickFromRoom:(NSString *)targetId byUserId:(NSString *)userId;


/// 网络延迟
/// @param rtt 单位ms
- (void)networkStatus:(NSInteger)rtt;

/// PK 运行的回调，如果PK连接成功，或者进入正在进行PK的房间均会触发此回调
/// @param inviterRoomId 邀请 PK 的用户id
/// @param inviterUserId 邀请 PK 的用户房间id
/// @param inviteeRoomId 被邀请 PK 的用户id
/// @param inviteeUserId 被邀请 PK 的用户房间id
- (void)pkOngoingWithInviterRoom:(NSString *)inviterRoomId
               withInviterUserId:(NSString *)inviterUserId
                 withInviteeRoom:(NSString *)inviteeRoomId
               withInviteeUserId:(NSString *)inviteeUserId;

/// PK 结束回调，任意一方结束 PK 均会触发此回调
- (void)pkDidFinish;

/// 收到邀请 PK 的回调
/// @param inviterRoomId 邀请者的房间id
/// @param inviterUserId 邀请者的用户id
- (void)pkInviteDidReceiveFromRoom:(NSString *)inviterRoomId byUser:(NSString *)inviterUserId;

/// 邀请者取消 PK 邀请回调
/// @param inviterRoomId 邀请者的房间id
/// @param inviterUserId 邀请者的用户id
- (void)cancelPKInviteDidReceiveFromRoom:(NSString *)inviterRoomId byUser:(NSString *)inviterUserId;

/// 被邀请者拒绝 PK 邀请回调
/// @param inviteeRoomId 被邀请者的房间id
/// @param initeeUserId 被邀请者的用户id
- (void)rejectPKInviteDidReceiveFromRoom:(NSString *)inviteeRoomId byUser:(NSString *)initeeUserId;

@end

NS_ASSUME_NONNULL_END
