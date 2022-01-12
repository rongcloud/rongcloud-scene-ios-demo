//
//  RCChatroomSceneToolBarConfig.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/3.
//

#import <UIKit/UIKit.h>
#import <RCChatroomSceneDefine.h>
#import <YYModel/YYModel.h>
NS_ASSUME_NONNULL_BEGIN


@interface RCChatroomSceneToolBarConfig : NSObject

/// 背景色
@property (nonatomic, strong) UIColor *backgroundColor;
/// 工具栏内边距
@property (nonatomic, assign) UIEdgeInsets contentInsets;
/// 消息按钮标题
@property (nonatomic, copy) NSString *chatButtonTitle;
/// 消息按钮大小
@property (nonatomic, assign) CGSize chatButtonSize;
/// 输入框按钮内边距
@property (nonatomic, assign) UIEdgeInsets chatButtonInsets;
/// 输入框按钮文字颜色
@property (nonatomic, strong) UIColor *chatButtonTextColor;
/// 输入框按钮文字大小
@property (nonatomic, assign) CGFloat chatButtonTextSize;
/// 输入框按钮背景色
@property (nonatomic, strong) UIColor *chatButtonBackgroundColor;
/// 输入框按钮背景圆角
@property (nonatomic, assign) CGFloat chatButtonBackgroundCorner;


/// 录音按钮是否可用
@property (nonatomic, assign) BOOL recordButtonEnable;
/// 录音质量
@property (nonatomic, assign) RCChatroomSceneRecordQuality recordQuality;
/// 录音按钮位置，0，左，1右
@property (nonatomic, assign) RCChatroomSceneRecordButtonPosition recordButtonPosition;
/// 录音最大时长
@property (nonatomic, assign) CGFloat recordMaxDuration;

/// 常用功能按钮
@property (nonatomic, strong) NSArray<UIView *> *commonActions;
/// 功能按钮
@property (nonatomic, strong) NSArray<UIView *> *actions;

+ (instancetype)default;
- (void)merge:(RCChatroomSceneToolBarConfig *)config;

@end

NS_ASSUME_NONNULL_END
