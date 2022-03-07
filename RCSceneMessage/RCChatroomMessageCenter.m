//
//  ChatroomMessageCenter.m
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//



#import "RCChatroomGift.h"
#import "RCChatroomLike.h"
#import "RCChatroomEnter.h"
#import "RCChatroomLeave.h"
#import "RCChatroomAdmin.h"
#import "RCChatroomSeats.h"
#import "RCVRVoiceMessage.h"
#import "RCChatroomFollow.h"
#import "RCChatroomBarrage.h"
#import "RCChatroomKickOut.h"
#import "RCChatroomGiftAll.h"

#import "RCChatroomMessageCenter.h"

@implementation RCChatroomMessageCenter

+ (void)registerMessageTypes {
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomEnter class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomLeave class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomBarrage class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomKickOut class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomGift class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomGiftAll class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomAdmin class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomSeats class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomLike class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCVRVoiceMessage class]];
    [[RCCoreClient sharedCoreClient] registerMessageType:[RCChatroomFollow class]];
}

+ (void)sendChatMessage:(NSString *)roomId
                content:(RCMessageContent *)content
                result:(RCCSResult)result {
    [RCChatroomMessageCenter sendChatMessage:roomId
                                     content:content
                                       queue:dispatch_get_main_queue()
                                      result:result];
}

+ (void)sendChatMessage:(NSString *)roomId
                content:(RCMessageContent *)content
                  queue:(dispatch_queue_t)queue
                 result:(RCCSResult)result {
    [[RCCoreClient sharedCoreClient] sendMessage:ConversationType_CHATROOM
                                        targetId:roomId
                                         content:content
                                     pushContent:nil
                                        pushData:nil
                                         success:^(long messageId) {
        dispatch_async(queue, ^{
            result(RC_SUCCESS, messageId);
        });
    }
                                           error:^(RCErrorCode nErrorCode, long messageId) {
        dispatch_async(queue, ^{
            result(nErrorCode, messageId);
        });
    }];
}

@end
