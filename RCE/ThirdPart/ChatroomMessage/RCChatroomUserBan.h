
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomUserBan : RCMessageContent

/**
 用户 Id
*/

@property(nonatomic, copy) NSString *id;


/**
 被禁言时长，单位: 分钟
*/

@property(nonatomic, assign) int duration;


/**
 附加信息
*/

@property(nonatomic, copy) NSString *extra;



@end
