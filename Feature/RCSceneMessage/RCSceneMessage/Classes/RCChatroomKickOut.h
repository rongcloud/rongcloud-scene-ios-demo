
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomKickOut : RCMessageContent

/**
 踢出用户 Id
*/
@property(nonatomic, copy) NSString *userId;

/**
 踢出用户 名称
*/
@property(nonatomic, copy) NSString *userName;

/**
 被踢出用户 Id
*/
@property(nonatomic, copy) NSString *targetId;

/**
 被踢出用户 名称
*/
@property(nonatomic, copy) NSString *targetName;

@end
