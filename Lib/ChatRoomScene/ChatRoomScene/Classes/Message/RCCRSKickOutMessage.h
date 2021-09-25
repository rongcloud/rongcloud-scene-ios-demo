//
//  RCMCKickOutMessage.h
//  RCE
//
//  Created by shaoshuai on 2021/7/15.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

/// 踢出房间
@interface RCCRSKickOutMessage : RCMessageContent

/// 操作者的用户信息
@property (nonatomic, strong, nonnull) RCUserInfo *userInfo;
/// 被踢出的用户信息
@property (nonatomic, strong, nonnull) NSArray<RCUserInfo *> *targetUserInfos;

@end

NS_ASSUME_NONNULL_END
