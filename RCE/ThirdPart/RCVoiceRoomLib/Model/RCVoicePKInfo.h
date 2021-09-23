//
//  RCVoicePKInfo.h
//  RCE
//
//  Created by 叶孤城 on 2021/8/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCVoicePKInfo : NSObject

@property (nonatomic, copy, nonnull) NSString *inviterUserId;
@property (nonatomic, copy, nonnull) NSString *inviterRoomId;
@property (nonatomic, copy, nonnull) NSString *inviteeUserId;
@property (nonatomic, copy, nonnull) NSString *inviteeRoomId;

- (instancetype)initWithInviterId:(NSString *)inviterUserId
                    inviterRoomId:(NSString *)inviterRoomId
                        inviteeId:(NSString *)inviteeUserId
                    inviteeRoomId:(NSString *)inviteeRoomId;

/// 类方法，根据jsonString生成一个RCVoiceSeatInfo实例
/// @param jsonSting RCVoiceSeatInfo的jsonSting
+ (RCVoicePKInfo *)modelWithJSON:(NSString *)jsonSting;

/// 自动生成该类对应的json字符串
- (NSString *)jsonString;


@end

NS_ASSUME_NONNULL_END
