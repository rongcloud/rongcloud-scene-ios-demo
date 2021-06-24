
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomBarrage : RCMessageContent

/**
 用户id
*/
@property(nonatomic, copy, nonnull) NSString *userId;

/**
 用户名称
*/
@property(nonatomic, copy, nonnull) NSString *userName;


/**
 弹幕内容
*/
@property(nonatomic, copy, nonnull) NSString *content;

@end
