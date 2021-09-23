//
//  RCCRSGiftMessage.h
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@class RCUserInfo, RCCRSGiftModel;

@interface RCCRSGiftMessage : RCMessageContent

/// 发送者信息
@property(nonatomic, strong, nonnull) RCUserInfo *userInfo;

/// 被赠送用户信息
@property(nonatomic, strong, nonnull) NSArray<RCUserInfo *> *targetUserInfos;

/// 礼物信息
@property(nonatomic, strong, nonnull) RCCRSGiftModel *gift;

@end

NS_ASSUME_NONNULL_END
