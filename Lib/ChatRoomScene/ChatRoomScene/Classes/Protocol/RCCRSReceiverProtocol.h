//
//  RCCRSReceiverProtocol.h
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class
RCCRSGiftMessage,
RCCRSLikeMessage,
RCCRSKickOutMessage,
RCCRSSetAdminMessage,
RCCRSCancelAdminMessage;

@protocol RCCRSReceiverProtocol <NSObject>

@optional

/// 接收到赠送礼物消息
/// @param message 礼物信息
- (void)giftMessageDidReceive:(RCCRSGiftMessage *)message;

/// 接收到点赞消息
/// @param message 点赞信息
- (void)likeMessageDidReceive:(RCCRSLikeMessage *)message;

/// 接收到踢出房间消息
/// @param message 踢出信息
- (void)kickOutMessageDidReceive:(RCCRSKickOutMessage *)message;

/// 接收到设置管理员消息
/// @param message 管理员信息
- (void)setAdminMessageDidReceive:(RCCRSSetAdminMessage *)message;

/// 接收到取消管理员消息
/// @param message 管理员信息
- (void)cancelAdminMessageDidReceive:(RCCRSCancelAdminMessage *)message;

/// 接收到欢迎语更新消息
/// @param message 欢迎语信息
- (void)welcomeDidUpdate:(RCTextMessage *)message;

/// 接收到公告更新消息
/// @param message 公告信息
- (void)announcementDidUpdate:(RCTextMessage *)message;

@end

NS_ASSUME_NONNULL_END
