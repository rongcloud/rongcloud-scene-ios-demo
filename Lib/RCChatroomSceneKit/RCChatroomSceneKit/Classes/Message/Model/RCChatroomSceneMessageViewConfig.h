//
//  RCChatroomSceneMessageViewConfig.h
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/7.
//

#import <Foundation/Foundation.h>
@class RCConner;
NS_ASSUME_NONNULL_BEGIN

@interface RCChatroomSceneMessageViewConfig : NSObject
/// 消息列表距离四周的距离
@property (nonatomic, assign) UIEdgeInsets contentInsets;
/// 最大显示的消息数量，超过最大数量移除顶部消息
@property (nonatomic, assign) NSInteger maxVisibleCount;
/// 消息气泡的默认颜色，优先级低于自定义
@property (nonatomic, strong) UIColor *defaultBubbleColor;
/// 消息气泡内部边距
@property (nonatomic, assign) UIEdgeInsets bubbleInsets;
///消息气泡的默认圆角，优先级低于自定义
@property (nonatomic, strong) RCConner *defaultBubbleCorner;
/// 消息气泡的默认文字颜色，优先级低于自定义
@property (nonatomic, strong) UIColor *defaultBubbleTextColor;
/// 消息气泡内部边距
@property (nonatomic, assign) CGFloat bubbleSpace;
/// 语音消息图标及时长文字的颜色
@property (nonatomic, strong) UIColor *voiceIconColor;

+ (instancetype)default;
- (void)merge:(RCChatroomSceneMessageViewConfig *)config;
@end

NS_ASSUME_NONNULL_END
