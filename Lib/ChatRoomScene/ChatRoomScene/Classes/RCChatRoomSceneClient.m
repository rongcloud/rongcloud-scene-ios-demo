//
//  RCChatRoomSceneClient.m
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

#import "RCChatRoomSceneClient.h"

#import <RongIMLib/RongIMLib.h>
#import <RongChatRoom/RongChatRoom.h>

#import "RCResult.h"
#import "RCCRSReceiverProtocol.h"
#import "RCCRSHandlerProtocol.h"
#import "RCCRSMessages.h"

NSString * const kRCMessageCenter_KVName_Welcome = @"welcome";
NSString * const kRCMessageCenter_KVName_Announcement = @"announcement";

@interface RCChatRoomSceneClient () <RCChatRoomStatusDelegate, RCChatRoomKVStatusChangeDelegate>

@property (nonatomic, strong) NSHashTable<id<RCChatRoomStatusDelegate>> *chatRoomStateDelegates;
@property (nonatomic, strong) NSHashTable<id<RCChatRoomKVStatusChangeDelegate>> *kvDelegates;
@property (nonatomic, strong) NSHashTable<id<RCCRSReceiverProtocol>> *receivers;
@property (nonatomic, strong) NSString *roomId;

@end

@implementation RCChatRoomSceneClient

+ (instancetype)shared {
    static RCChatRoomSceneClient *instance;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[RCChatRoomSceneClient alloc] init];
        [[RCChatRoomClient sharedChatRoomClient] setChatRoomStatusDelegate:instance];
        [[RCChatRoomClient sharedChatRoomClient] setRCChatRoomKVStatusChangeDelegate:instance];
        [[RCCoreClient sharedCoreClient] registerMessageType:[RCCRSGiftMessage class]];
        [[RCCoreClient sharedCoreClient] registerMessageType:[RCCRSLikeMessage class]];
        [[RCCoreClient sharedCoreClient] registerMessageType:[RCCRSKickOutMessage class]];
        [[RCCoreClient sharedCoreClient] registerMessageType:[RCCRSSetAdminMessage class]];
        [[RCCoreClient sharedCoreClient] registerMessageType:[RCCRSCancelAdminMessage class]];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chatRoomStateDelegates = [NSHashTable weakObjectsHashTable];
        _kvDelegates = [NSHashTable weakObjectsHashTable];
        _receivers = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)addChatRoomStatusDelegate:(id<RCChatRoomStatusDelegate>)delegate {
    [_chatRoomStateDelegates addObject:delegate];
}

- (void)removeChatRoomStatusDelegate:(id<RCChatRoomStatusDelegate>)delegate {
    [_chatRoomStateDelegates removeObject:delegate];
}

#pragma mark - RCChatRoomStatusDelegate -

- (void)onChatRoomJoining:(NSString *)chatroomId {
    for (id<RCChatRoomStatusDelegate> delegate in _chatRoomStateDelegates) {
        [delegate onChatRoomJoining:chatroomId];
    }
}

- (void)onChatRoomJoined:(NSString *)chatroomId {
    _roomId = chatroomId;
    for (id<RCChatRoomStatusDelegate> delegate in _chatRoomStateDelegates) {
        [delegate onChatRoomJoined:chatroomId];
    }
}

- (void)onChatRoomJoinFailed:(NSString *)chatroomId errorCode:(RCErrorCode)errorCode {
    for (id<RCChatRoomStatusDelegate> delegate in _chatRoomStateDelegates) {
        [delegate onChatRoomJoinFailed:chatroomId errorCode:errorCode];
    }
}

- (void)onChatRoomQuited:(NSString *)chatroomId {
    _roomId = nil;
    for (id<RCChatRoomStatusDelegate> delegate in _chatRoomStateDelegates) {
        [delegate onChatRoomQuited:chatroomId];
    }
}

- (void)onChatRoomReset:(NSString *)chatroomId {
    for (id<RCChatRoomStatusDelegate> delegate in _chatRoomStateDelegates) {
        [delegate onChatRoomReset:chatroomId];
    }
}

- (void)onChatRoomDestroyed:(NSString *)chatroomId type:(RCChatRoomDestroyType)type {
    _roomId = nil;
    for (id<RCChatRoomStatusDelegate> delegate in _chatRoomStateDelegates) {
        [delegate onChatRoomDestroyed:chatroomId type:type];
    }
}

#pragma mark -

- (void)addChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate {
    [_kvDelegates addObject:delegate];
}

- (void)removeChatRoomKVStatusChangeDelegate:(id<RCChatRoomKVStatusChangeDelegate>)delegate {
    [_kvDelegates removeObject:delegate];
}

#pragma mark - RCChatRoomKVStatusChangeDelegate -

- (void)chatRoomKVDidSync:(NSString *)roomId {
    for (id<RCChatRoomKVStatusChangeDelegate> delegate in _kvDelegates) {
        if (delegate != nil && [delegate respondsToSelector:@selector(chatRoomKVDidSync:)]) {
            [delegate chatRoomKVDidSync:roomId];
        }
    }
}

- (void)chatRoomKVDidUpdate:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    for (id<RCChatRoomKVStatusChangeDelegate> delegate in _kvDelegates) {
        if (delegate != nil && [delegate respondsToSelector:@selector(chatRoomKVDidUpdate:entry:)]) {
            [delegate chatRoomKVDidUpdate:roomId entry:entry];
        }
    }
    if (entry.allKeys.count > 1) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self chatRoomKVDidUpdateHandler:roomId entry:entry];
    });
}

- (void)chatRoomKVDidUpdateHandler:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    if ([entry.allKeys containsObject:kRCMessageCenter_KVName_Welcome]) {
        NSString *welcome = entry[kRCMessageCenter_KVName_Welcome];
        RCTextMessage *message = [RCTextMessage messageWithContent:welcome];
        for (id<RCCRSReceiverProtocol> receiver in self.receivers) {
            [receiver welcomeDidUpdate:message];
        }
    } else if ([entry.allKeys containsObject:kRCMessageCenter_KVName_Announcement]) {
        NSString *announcement = entry[kRCMessageCenter_KVName_Announcement];
        RCTextMessage *message = [RCTextMessage messageWithContent:announcement];
        for (id<RCCRSReceiverProtocol> receiver in self.receivers) {
            [receiver announcementDidUpdate:message];
        }
    }
}

- (void)chatRoomKVDidRemove:(NSString *)roomId entry:(NSDictionary<NSString *,NSString *> *)entry {
    for (id<RCChatRoomKVStatusChangeDelegate> delegate in _kvDelegates) {
        if (delegate != nil && [delegate respondsToSelector:@selector(chatRoomKVDidRemove:entry:)]) {
            [delegate chatRoomKVDidRemove:roomId entry:entry];
        }
    }
}

#pragma mark -

@end

@implementation RCChatRoomSceneClient (sender)

- (void)sendMessage:(RCMessageContent *)content completion:(RCResultBlock)completion {
    if (_roomId == nil) {
        NSString *errorMsg = @"没有加入房间";
        NSError *error = [NSError errorWithDomain:@"ChatRoomScene://Message"
                                             code:ERRORCODE_UNKNOWN
                                         userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
        completion([RCResult failure:error]);
        return;
    }
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM
                                      targetId:_roomId
                                       content:content
                                   pushContent:nil
                                      pushData:nil
                                       success:^(long messageId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion([RCResult success:@(messageId)]);
        });
    }
                                         error:^(RCErrorCode nErrorCode, long messageId) {
        NSString *errorMsg = @"消息发送失败";
        NSError *error = [NSError errorWithDomain:@"ChatRoomScene://Message"
                                             code:nErrorCode
                                         userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion([RCResult failure:error]);
        });
    }];
}

- (void)updateKV:(NSString *)key value:(NSString *)value completion:(RCResultBlock)completion {
    if (_roomId == nil) {
        NSString *errorMsg = @"没有加入房间";
        NSError *error = [NSError errorWithDomain:@"ChatRoomScene://KV"
                                             code:ERRORCODE_UNKNOWN
                                         userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
        completion([RCResult failure:error]);
        return;
    }
    [[RCChatRoomClient sharedChatRoomClient] forceSetChatRoomEntry:_roomId
                                                               key:key
                                                             value:value
                                                  sendNotification:NO
                                                        autoDelete:NO
                                                 notificationExtra:@""
                                                           success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion([RCResult success:value]);
        });
    } error:^(RCErrorCode nErrorCode) {
        NSString *errorMsg = @"KV更新失败";
        NSError *error = [NSError errorWithDomain:@"ChatRoomScene://KV"
                                             code:nErrorCode
                                         userInfo:@{NSLocalizedDescriptionKey: errorMsg}];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion([RCResult failure:error]);
        });
    }];
}

#pragma mark - API -

- (void)sendGiftMessage:(RCCRSGiftMessage *)message completion:(RCResultBlock)completion {
    [self sendMessage:message completion:completion];
}

- (void)sendLikeMessage:(RCCRSLikeMessage *)message completion:(RCResultBlock)completion {
    [self sendMessage:message completion:completion];
}

- (void)sendKickOutMessage:(RCCRSKickOutMessage *)message completion:(RCResultBlock)completion {
    [self sendMessage:message completion:completion];
}

- (void)sendSetAdminMessage:(RCCRSSetAdminMessage *)message completion:(RCResultBlock)completion {
    [self sendMessage:message completion:completion];
}

- (void)sendCancelAdminMessage:(RCCRSCancelAdminMessage *)message completion:(RCResultBlock)completion {
    [self sendMessage:message completion:completion];
}

- (void)updateWelcome:(RCTextMessage *)message completion:(RCResultBlock)completion {
    [self updateKV:kRCMessageCenter_KVName_Welcome value:message.content completion:completion];
}

- (void)updateAnnouncement:(RCTextMessage *)message completion:(RCResultBlock)completion {
    [self updateKV:kRCMessageCenter_KVName_Announcement value:message.content completion:completion];
}

#pragma mark -

@end

@implementation RCChatRoomSceneClient (receiver)

- (void)addReceiver:(id<RCCRSReceiverProtocol>)receiver {
    [_receivers addObject:receiver];
}

- (void)removeReceiver:(id<RCCRSReceiverProtocol>)receiver {
    [_receivers removeObject:receiver];
}

@end

@implementation RCChatRoomSceneClient (handler)

- (void)handleChatRoomMessage:(RCMessage *)message {
    if (message.conversationType != ConversationType_CHATROOM) return;
    if (message.targetId != _roomId) return;
    if ([message.content conformsToProtocol:@protocol(RCCRSHandlerProtocol)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            id<RCCRSHandlerProtocol> handler = (id<RCCRSHandlerProtocol>)message.content;
            for (id<RCCRSReceiverProtocol> receiver in self.receivers) {
                [handler handleMessage:message toReceiver:receiver];
            }
        });
    } else {
        NSString *className = NSStringFromClass(message.content.class);
        NSLog(@"%@ not conforms to RCMCHandlerProtocol, auto ignored.", className);
    }
}

@end
