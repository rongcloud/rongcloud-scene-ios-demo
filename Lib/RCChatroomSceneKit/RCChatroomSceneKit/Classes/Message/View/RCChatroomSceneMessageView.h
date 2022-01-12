//
//  RCChatroomSceneMessageView.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol
RCChatroomSceneMessageProtocol,
RCChatroomSceneEventProtocol;

@class RCChatroomSceneMessageConfig;
@class RCChatroomSceneToolBar;

@interface RCChatroomSceneMessageView : UIView

/// 消息列表
@property (nonatomic, strong) UITableView *tableView;

/// 添加消息，消息需要实现 RCChatroomSceneMessageProtocol 协议
/// @param message 消息
- (void)addMessage:(id<RCChatroomSceneMessageProtocol>)message;

/// 设置消息点击事件代理
/// @param trackDelegate 代理
- (void)setEventDelegate:(id<RCChatroomSceneEventProtocol>)trackDelegate;

@end

NS_ASSUME_NONNULL_END
