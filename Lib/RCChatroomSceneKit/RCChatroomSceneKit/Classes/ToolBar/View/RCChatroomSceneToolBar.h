//
//  RCChatroomSceneToolBar.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCChatroomSceneToolBarDelegate <NSObject>

@optional

/// 文本输入点击发送后调用
/// @param text 文本内容
- (void)textInputViewSendText:(NSString *)text;

/// 判断是否能开启录音
- (BOOL)audioRecordShouldBegin;
/// 开始录音
- (void)audioRecordDidBegin;
/// 取消录音
- (void)audioRecordDidCancel;
/// 录音完成
/// @param NSData 音频文件
/// @param time 音频文件时长，单位：秒
- (void)audioRecordDidEnd:(nullable NSData *)data time:(NSTimeInterval)time;

@end

@class RCChatroomSceneToolBarConfig;
@interface RCChatroomSceneToolBar : UIView

@property (nonatomic, weak) id<RCChatroomSceneToolBarDelegate> delegate;

- (void)setConfig:(RCChatroomSceneToolBarConfig *)config;

@end

NS_ASSUME_NONNULL_END
