//
//  RCMessageCenterExtensionModule.m
//  RCE
//
//  Created by shaoshuai on 2021/7/20.
//

#import "RCChatRoomSceneExtensionModule.h"

#import "RCChatRoomSceneClient.h"
#import "RCCRSMessages.h"

@interface RCChatRoomSceneClient (handler)

- (void)handleChatRoomMessage:(RCMessage *)message;

@end

@implementation RCChatRoomSceneExtensionModule

+ (instancetype)loadRongExtensionModule {
    [RCChatRoomSceneClient shared];
    return [[RCChatRoomSceneExtensionModule alloc] init];
}

- (void)destroyModule {
}

- (NSArray<Class> *)getSignalMessageClassList {
    return @[
        [RCCRSGiftMessage class],
        [RCCRSLikeMessage class],
        [RCCRSKickOutMessage class],
        [RCCRSSetAdminMessage class],
        [RCCRSCancelAdminMessage class]
    ];
}

- (BOOL)didHoldReceivedMessage:(RCMessage *)message isOffline:(BOOL)offline {
    [[RCChatRoomSceneClient shared] handleChatRoomMessage:message];
    return NO;
}

- (void)setAppKey:(NSString *)appKey {
    
}

- (void)setConfiguration:(RCNaviDataInfo *)configuration {
    
}

- (void)setUserId:(NSString *)userId {
    
}

- (void)setCurrentToken:(NSString *)token {
    
}

- (void)notifyConnectionStatusChanged:(RCConnectionStatus)status {
    
}

- (void)notifyLogoutEvent {
    
}

- (void)setDeviceToken:(NSString *)deviceToken {
    
}

//是否占用音频
- (BOOL)isAudioHolding {
    return NO;
}

//是否占用视频
- (BOOL)isCameraHolding {
    return NO;
}

@end
