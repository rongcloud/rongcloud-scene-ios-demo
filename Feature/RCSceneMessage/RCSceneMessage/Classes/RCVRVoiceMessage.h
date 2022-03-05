//
//  RCChatroomVoiceMessage.h
//  RCE
//
//  Created by shaoshuai on 2021/8/3.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCVRVoiceMessage : RCMessageContent

/**
 用户 Id
*/
@property(nonatomic, copy) NSString *userId;

/**
 用户名称
*/
@property(nonatomic, copy) NSString *userName;

@property(nonatomic, copy) NSString *path;

@property(nonatomic, assign) NSUInteger duration;

@end

NS_ASSUME_NONNULL_END
