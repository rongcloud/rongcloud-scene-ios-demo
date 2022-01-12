//
//  RCChatroomSceneMessage.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/27.
//

#import <UIKit/UIKit.h>
@class RCConner;
NS_ASSUME_NONNULL_BEGIN

@protocol RCChatroomSceneMessageProtocol <NSObject>

@optional

/// 气泡颜色
- (UIColor *)bubbleColor;

/// 返回气泡文字颜色，返回 null 采用默认配置
- (UIColor *)bubbleTextColor;

/// 返回气泡文字颜色，返回 null 采用默认配置
- (RCConner *)bubbleCorner;

/// 点击事件，eventId: eventRange
/// eventId：事件标记，比如：用户 ID、礼物 ID 等
/// eventRange：标记事件在 attributeString 中的位置
- (NSDictionary<NSValue *, NSString *> *)events;

/// 富文本消息体
- (NSAttributedString *)attributeString;

@end

/// 消息事件标记被点击
@protocol RCChatroomSceneEventProtocol <NSObject>

- (void)cell:(UITableViewCell *)cell didClickEvent:(NSString *)eventId;

@end

/// 语音消息
@protocol RCChatroomSceneVoiceMessage <RCChatroomSceneMessageProtocol>

/// 语音文件本地路径
- (NSString *)voicePath;

/// 语音时长
- (long)voiceDuration;

@end

NS_ASSUME_NONNULL_END
