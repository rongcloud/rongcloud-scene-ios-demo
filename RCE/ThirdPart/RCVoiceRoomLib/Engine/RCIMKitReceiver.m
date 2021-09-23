//
//  RCKitMessageReceiver.m
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

#import "RCIMKitReceiver.h"
#import <RongRTCLib/RongRTCLib.h>

@interface RCIMKitReceiver ()

@property (nonatomic, strong) id client;
@property (nonatomic, weak) id<RCIMClientReceiveMessageDelegate> delegate;

@end

@implementation RCIMKitReceiver

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (instancetype)init {
    self = [super init];
    if(self) {
        _client = [NSClassFromString(@"RCIM") performSelector:NSSelectorFromString(@"sharedRCIM")];
        [_client performSelector:NSSelectorFromString(@"setReceiveMessageDelegate:") withObject:self];
    }
    return self;
}

#pragma mark - RCIMReceiveMessageDelegate

- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left {
    [_delegate onReceived:message left:left object:nil];
}

- (BOOL)onRCIMCustomAlertSound:(RCMessage *)message {
    return true;
}

#pragma mark - RCVoiceRoomClientProtocol

- (void)initWithAppKey:(NSString *)appKey {
    [_client performSelector:NSSelectorFromString(@"initWithAppKey:") withObject:appKey];
}

- (void)connectWithToken:(NSString *)token
                dbOpened:(void (^)(RCDBErrorCode code))dbOpenedBlock
                 success:(void (^)(NSString *userId))successBlock
                   error:(void (^)(RCConnectErrorCode errorCode))errorBlock {
    SEL selector = NSSelectorFromString(@"connectWithToken:dbOpened:success:error:");
    NSMethodSignature *signature = [[_client class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = _client;
    invocation.selector = selector;
    [invocation setArgument:&token atIndex:2];
    [invocation setArgument:&dbOpenedBlock atIndex:3];
    [invocation setArgument:&successBlock atIndex:4];
    [invocation setArgument:&errorBlock atIndex:5];
    [invocation invoke];
}
- (void)disconnect:(BOOL)push {
    [_client performSelector:NSSelectorFromString(@"disconnect:") withObject:@(push)];
}

- (void)registerMessageType:(Class)messageClass {
    [_client performSelector:NSSelectorFromString(@"registerMessageType:") withObject:messageClass];
}

- (void)setReceiveMessageDelegate:(id<RCIMClientReceiveMessageDelegate>)delegate {
    [_client performSelector:NSSelectorFromString(@"setReceiveMessageDelegate:") withObject:self];
    _delegate = delegate;
}

- (void)sendMessage:(NSString *)targetId
            content:(RCMessageContent *)content
            success:(void (^)(long messageId))successBlock
              error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock {
    SEL selector = NSSelectorFromString(@"sendMessage:targetId:content:pushContent:pushData:success:error:");
    NSMethodSignature *signature = [[_client class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) return;
    RCConversationType type = ConversationType_CHATROOM;
    NSString *pushContent = nil;
    NSString *pushData = nil;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = _client;
    invocation.selector = selector;
    [invocation setArgument:&type atIndex:2];
    [invocation setArgument:&targetId atIndex:3];
    [invocation setArgument:&content atIndex:4];
    [invocation setArgument:&pushContent atIndex:5];
    [invocation setArgument:&pushData atIndex:6];
    [invocation setArgument:&successBlock atIndex:7];
    [invocation setArgument:&errorBlock atIndex:8];
    [invocation invoke];
}

#pragma clang diagnostic pop

@end
