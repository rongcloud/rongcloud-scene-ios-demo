//
//  ChatroomMessageCenter.m
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

#import "RCChatroomMessageCenter.h"

#ifdef __has_include
#if __has_include(<RongIMKit/RongIMKit.h>)
#import <RongIMKit/RongIMKit.h>
#define CMPTIMKit YES
#endif
#endif

#ifdef CMPTIMKit
#define RCIMReceiveMessageDelegate RCIMReceiveMessageDelegate
#define RCClient [RCIM sharedRCIM]
#else
#define RCIMReceiveMessageDelegate RCIMClientReceiveMessageDelegate
#define RCClient [RCCoreClient sharedCoreClient]
#endif

@implementation RCChatroomMessageCenter

+ (void)registerMessageTypes {
    [RCClient registerMessageType:[RCChatroomBarrage class]];
    [RCClient registerMessageType:[RCChatroomKickOut class]];
    [RCClient registerMessageType:[RCChatroomGift class]];
    [RCClient registerMessageType:[RCChatroomGiftAll class]];
    [RCClient registerMessageType:[RCChatroomAdmin class]];
    [RCClient registerMessageType:[RCChatroomSeats class]];
    [RCClient registerMessageType:[RCChatroomLike class]];
}

+ (void)sendChatMessage:(NSString *)roomId content:(RCMessageContent *)content
                success:(RCChatroomMessageSuccess)success
                  error:(RCChatroomMessageError)error {
    [RCChatroomMessageCenter sendChatMessage:roomId
                                     content:content
                                       queue:dispatch_get_main_queue()
                                     success:success
                                       error:error];
}

+ (void)sendChatMessage:(NSString *)roomId
                content:(RCMessageContent *)content
                  queue:(dispatch_queue_t)queue
                success:(RCChatroomMessageSuccess)success
                  error:(RCChatroomMessageError)error {
    [RCClient sendMessage:ConversationType_CHATROOM
                 targetId:roomId
                  content:content
              pushContent:nil
                 pushData:nil
                  success:^(long messageId) {
        dispatch_async(queue, ^{
            success(messageId);
        });
    }
                    error:^(RCErrorCode nErrorCode, long messageId) {
        dispatch_async(queue, ^{
            error(nErrorCode, messageId);
        });
    }];
}

@end
