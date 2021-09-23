//
//  RCLibMessageWrapper.m
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

#import "RCIMLibReceiver.h"
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCIMLibReceiver ()

@end

@implementation RCIMLibReceiver

#pragma mark - RCVoiceRoomClientProtocol -

- (void)initWithAppKey:(NSString *)appKey {
    [[RCCoreClient sharedCoreClient] initWithAppKey:appKey];
}

- (void)connectWithToken:(NSString *)token
                dbOpened:(void (^)(RCDBErrorCode code))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode errorCode))errorBlock {
    [[RCCoreClient sharedCoreClient] connectWithToken:token dbOpened:dbOpenedBlock success:successBlock error:errorBlock];
}
- (void)disconnect:(BOOL)push {
    [[RCCoreClient sharedCoreClient] disconnect:push];
}

- (void)registerMessageType:(Class)messageClass {
    [[RCCoreClient sharedCoreClient] registerMessageType:messageClass];
}

- (void)setReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate {
    [[RCCoreClient sharedCoreClient] setReceiveMessageDelegate:delegate object:nil];
}

- (void)sendMessage:(NSString *)targetId
            content:(RCMessageContent *)content
            success:(void (^)(long messageId))successBlock
              error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock {
    [[RCCoreClient sharedCoreClient] sendMessage:ConversationType_CHATROOM targetId:targetId content:content pushContent:nil pushData:nil success:successBlock error:errorBlock];
}

@end
