
#import <RongIMLibCore/RongIMLibCore.h>

@interface RCChatroomGift : RCMessageContent

/**
 用户id
*/
@property(nonatomic, copy) NSString *userId;

/**
 用户名称
*/
@property(nonatomic, copy) NSString *userName;

/**
 被赠送用户id
*/
@property(nonatomic, copy) NSString *targetId;

/**
 被赠送用户名称
*/
@property(nonatomic, copy) NSString *targetName;

/**
 礼物编号
*/
@property(nonatomic, copy) NSString *giftId;

/**
 礼物名称
*/
@property(nonatomic, copy) NSString *giftName;

/**
 本次发送礼物数量
*/
@property(nonatomic, assign) NSInteger number;

/**
 本次发送礼物价格
*/
@property(nonatomic, assign) NSInteger price;

@end
