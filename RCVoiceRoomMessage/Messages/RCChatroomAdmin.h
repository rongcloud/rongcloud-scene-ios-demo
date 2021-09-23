
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomAdmin : RCMessageContent

/**
 用户 Id
*/
@property(nonatomic, copy) NSString *userId;

/**
 用户名称
*/
@property(nonatomic, copy) NSString *userName;

/**
 是否是管理者
*/
@property(nonatomic, assign) BOOL isAdmin;

@end
