
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomFollow : RCMessageContent

/**
 关注用户信息
*/
@property(nonatomic, strong, nonnull) RCUserInfo *userInfo;


/**
 被关注用户信息
*/
@property(nonatomic, strong, nonnull) RCUserInfo *targetUserInfo;

@end
