//
//  RCCRSHandlerProtocol.h
//  RCE
//
//  Created by shaoshuai on 2021/7/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RCMessage;
@protocol RCCRSReceiverProtocol;
@protocol RCCRSHandlerProtocol <NSObject>

/// 消息处理
/// @param message 接收到的消息
/// @param receiver 消息接收者
- (void)handleMessage:(RCMessage *)message toReceiver:(id<RCCRSReceiverProtocol>)receiver;

@end

NS_ASSUME_NONNULL_END
