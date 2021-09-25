//
//  RCChatroomMessageCenter.h
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

#import <RongIMLibCore/RongIMLibCore.h>

#import "RCChatroomEnter.h"
#import "RCChatroomLeave.h"
#import "RCChatroomBarrage.h"
#import "RCChatroomKickOut.h"
#import "RCChatroomGift.h"
#import "RCChatroomGiftAll.h"
#import "RCChatroomAdmin.h"
#import "RCChatroomSeats.h"
#import "RCChatroomLike.h"
#import "RCVRVoiceMessage.h"
#import "RCChatroomFollow.h"

typedef void(^RCChatroomMessageSuccess)(long messageId);
typedef void(^RCChatroomMessageError)(RCErrorCode errorCode, long messageId);

NS_ASSUME_NONNULL_BEGIN

@protocol RCChatroomLocalMessageDelegate <NSObject>

- (void)didReceiveLocalChatroomMessage:(RCMessageContent *)content;

@end

@interface RCChatroomMessageCenter : NSObject

///注册消息类
+ (void)registerMessageTypes;

///发送消息
///@param roomId 房间id
///@param content 消息，对应自定义消息类型
+ (void)sendChatMessage:(NSString *)roomId
                content:(RCMessageContent *)content
                success:(RCChatroomMessageSuccess)success
                  error:(RCChatroomMessageError)error;

///发送消息
///@param roomId 房间id
///@param content 消息，对应自定义消息类型
///@param queue 回调线程
+ (void)sendChatMessage:(NSString *)roomId
                content:(RCMessageContent *)content
                  queue:(dispatch_queue_t)queue
                success:(RCChatroomMessageSuccess)success
                  error:(RCChatroomMessageError)error;

@end

NS_ASSUME_NONNULL_END
