//
//  RCChatroomSceneInputBarConfig.h
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCChatroomSceneInputBarConfig : NSObject

/// 背景色
@property (nonatomic, strong) UIColor *backgroundColor;
/// InputBar内边距
@property (nonatomic, assign) UIEdgeInsets contentInsets;
/// 输入框背景色
@property (nonatomic, strong) UIColor *inputBackgroundColor;
/// 输入框圆角
@property (nonatomic, assign) CGFloat inputCorner;
/// 输入最大文字长度
@property (nonatomic, assign) NSInteger inputTextMaxLength;
/// 输入框最小高度
@property (nonatomic, assign) CGFloat inputMinHeight;
/// 输入框最大高度，输入文字多行时的最大高度
@property (nonatomic, assign) CGFloat inputMaxHeight;
/// 输入框内文字大小
@property (nonatomic, assign) CGFloat inputTextSize;
/// 输入框内文字颜色
@property (nonatomic, strong) UIColor *inputTextColor;
/// 输入框内默认提示文字
@property (nonatomic, copy) NSString *inputHint;
/// 输入框内默认提示文字颜色
@property (nonatomic, strong) UIColor *inputHintColor;
/// 输入框内边距
@property (nonatomic, assign) UIEdgeInsets inputInsets;
///是否开启emoji输入功能
@property (nonatomic, assign) BOOL emojiEnable;
/// 自定义表情视图
@property (nonatomic, strong) UIView *inputEmojiView;

+ (instancetype)default;
- (void)merge:(RCChatroomSceneInputBarConfig *)config;
@end

NS_ASSUME_NONNULL_END
