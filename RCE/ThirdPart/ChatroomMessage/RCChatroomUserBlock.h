
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomUserBlock : RCMessageContent

/**
 被封禁的用户 Id
*/

@property(nonatomic, copy) NSString *id;


/**
 封禁时长，单位: 分钟
*/

@property(nonatomic, assign) int duration;


/**
 附加信息
*/

@property(nonatomic, copy) NSString *extra;



@end
