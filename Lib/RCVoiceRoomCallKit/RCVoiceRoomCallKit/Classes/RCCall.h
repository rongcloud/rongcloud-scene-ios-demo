//
//  RCCall.h
//  RongCallKit
//
//  Created by RongCloud on 16/3/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongCallLib/RongCallLib.h>

/// 新的 callsession 被创建时发出该通知
UIKIT_EXTERN NSNotificationName const RCCallNewSessionCreationNotification;

/*!
 融云CallKit核心类
 */
@interface RCCall : NSObject

/*!
 当前的通话会话实体
 */
@property (nonatomic, strong, readonly) RCCallSession *currentCallSession;

/*!
 系统来电显示的 app 名字
 */
@property (nonatomic, copy) NSString *appLocalizedName;

/*!
 是否处理来电, 默认: YES 处理, 设置为 NO 时会直接挂断来电
*/
@property (nonatomic, assign) BOOL canIncomingCall;

/*!
 获取融云通话界面组件CallKit的核心类单例

 @return 融云通话界面组件CallKit的核心类单例

 @discussion 您可以通过此方法，获取CallKit的单例，访问对象中的属性和方法.
 */
+ (instancetype)sharedRCCall;

/*!
 当前会话类型是否支持音频通话

 @param conversationType 会话类型

 @return 是否支持音频通话
 */
- (BOOL)isAudioCallEnabled:(RCConversationType)conversationType;

/*!
 当前会话类型是否支持视频通话

 @param conversationType 会话类型

 @return 是否支持视频通话
 */
- (BOOL)isVideoCallEnabled:(RCConversationType)conversationType;

/*!
 发起单人通话

 @param targetId  对方的用户ID
 @param mediaType 使用的媒体类型
 */
- (void)startSingleCall:(NSString *)targetId mediaType:(RCCallMediaType)mediaType;

#pragma mark - Utility
/*!
 弹出通话ViewController或选择成员ViewController

 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)presentCallViewController:(UIViewController *)viewController;

/*!
 取消通话ViewController或选择成员ViewController

 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)dismissCallViewController:(UIViewController *)viewController;

/*!
 停止来电铃声和震动
 */
- (void)stopReceiveCallVibrate;

/*!
 获取 SDK 版本号

 @return 版本号

 @remarks 参数配置
 */
+ (NSString *)getVersion;

@end
