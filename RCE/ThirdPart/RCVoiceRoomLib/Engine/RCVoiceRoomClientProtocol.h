//
//  RCVoiceRoomClientProtocol.h
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCVoiceRoomClientProtocol <NSObject>

- (void)initWithAppKey:(NSString *)appKey;

- (void)connectWithToken:(NSString *)token
                dbOpened:(void (^)(RCDBErrorCode code))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode errorCode))errorBlock;
- (void)disconnect:(BOOL)push;

- (void)registerMessageType:(Class)messageClass;

- (void)setReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate;

- (void)sendMessage:(NSString *)targetId
            content:(RCMessageContent *)content
            success:(void (^)(long messageId))successBlock
              error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;

@end

NS_ASSUME_NONNULL_END
