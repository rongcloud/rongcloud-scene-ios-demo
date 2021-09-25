//
//  RCMessageContentCancelAdmin.h
//  RCE
//
//  Created by shaoshuai on 2021/7/15.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@class RCCRSAdminMessage;

@interface RCCRSCancelAdminMessage : RCMessageContent

/// 发送者用户信息
@property (nonatomic, strong, nonnull) RCUserInfo *userInfo;

/// 被取消管理员的用户信息
@property (nonatomic, strong, nonnull) RCUserInfo *targetUserInfo;

@end

NS_ASSUME_NONNULL_END
