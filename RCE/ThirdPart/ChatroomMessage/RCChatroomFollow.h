
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomFollow : RCMessageContent

/**
 用户 Id
*/

@property(nonatomic, copy) NSString *id;


/**
 应用内的用户等级
*/

@property(nonatomic, assign) int rank;


/**
 用户在当前聊天室的级别
*/

@property(nonatomic, assign) int level;


/**
 附加信息
*/

@property(nonatomic, copy) NSString *extra;



@end
