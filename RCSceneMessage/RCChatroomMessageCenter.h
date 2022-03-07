//
//  RCChatroomMessageCenter.h
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

#import <RongIMLibCore/RongIMLibCore.h>

typedef void(^RCCSResult)(RCErrorCode code, long messageId);

NS_ASSUME_NONNULL_BEGIN

@interface RCChatroomMessageCenter : NSObject

///注册消息类
+ (void)registerMessageTypes;

///发送消息
///@param roomId 房间id
///@param content 消息，对应自定义消息类型
+ (void)sendChatMessage:(NSString *)roomId
                content:(RCMessageContent *)content
                result:(RCCSResult)result;

///发送消息
///@param roomId 房间id
///@param content 消息，对应自定义消息类型
///@param queue 回调线程
+ (void)sendChatMessage:(NSString *)roomId
                content:(RCMessageContent *)content
                  queue:(dispatch_queue_t)queue
result:(RCCSResult)result;

@end

NS_ASSUME_NONNULL_END
