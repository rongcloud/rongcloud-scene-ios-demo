//
//  RCChatRoomSceneClient.h
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

#import <Foundation/Foundation.h>

#import "RCCRSMessages.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCChatRoomKVStatusChangeDelegate, RCChatRoomStatusDelegate;
@interface RCChatRoomSceneClient : NSObject

+ (instancetype)shared;

#warning 请使用以下方法设置ChatRoomStatus监听
/// 添加状态变化代理
/// @param delegate 代理
- (void)addChatRoomStatusDelegate:(id<RCChatRoomStatusDelegate>)delegate NS_SWIFT_NAME(addChatRoomStatus(_:));

/// 移除状态变化代理
/// @param delegate 代理
- (void)removeChatRoomStatusDelegate:(id<RCChatRoomStatusDelegate>)delegate NS_SWIFT_NAME(removeChatRoomStatus(_:));

/// 添加KV更新代理
/// @param delegate 代理
- (void)addChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate NS_SWIFT_NAME(addChatRoomKVStatusChange(_:));

/// 移除KV更新代理
/// @param delegate 代理
- (void)removeChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate NS_SWIFT_NAME(removeChatRoomKVStatusChange(_:));

@end

///发送结果
@class RCResult;
typedef void(^RCResultBlock)(RCResult *);

@interface RCChatRoomSceneClient (sender)

/// 发送赠送礼物通知消息
/// @param message 赠送礼物消息内容
/// @param completion 消息发送结果
- (void)sendGiftMessage:(RCCRSGiftMessage *)message completion:(RCResultBlock)completion;

/// 发送点赞消息
/// @param message 点赞信息
/// @param completion 消息发送结果
- (void)sendLikeMessage:(RCCRSLikeMessage *)message completion:(RCResultBlock)completion;

/// 发送踢出房间消息
/// @param message 踢出房间信息
/// @param completion 消息发送结果
- (void)sendKickOutMessage:(RCCRSKickOutMessage *)message completion:(RCResultBlock)completion;

/// 发送设置管理员消息
/// @param message 设置管理员信息
/// @param completion 消息发送结果
- (void)sendSetAdminMessage:(RCCRSSetAdminMessage *)message completion:(RCResultBlock)completion;

/// 发送取消管理员消息
/// @param message 取消管理员信息
/// @param completion 消息发送结果
- (void)sendCancelAdminMessage:(RCCRSCancelAdminMessage *)message completion:(RCResultBlock)completion;

/// 设置欢迎语，采用KV更新
/// @param message 欢迎语信息
/// @param completion 消息发送结果
- (void)updateWelcome:(RCTextMessage *)message completion:(RCResultBlock)completion;

/// 设置公告，采用KV更新
/// @param message 公告信息
/// @param completion 消息发送结果
- (void)updateAnnouncement:(RCTextMessage *)message completion:(RCResultBlock)completion;

@end

@protocol RCCRSReceiverProtocol;
@interface RCChatRoomSceneClient (receiver)

/// 添加接收者
/// @param receiver 接收者
- (void)addReceiver:(id<RCCRSReceiverProtocol>)receiver;

/// 删除接收者
/// @param receiver 接收者
- (void)removeReceiver:(id<RCCRSReceiverProtocol>)receiver;

@end

NS_ASSUME_NONNULL_END
