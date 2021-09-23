//
//  RCUserInfo+Coding.h
//  ChatRoomScene
//
//  Created by shaoshuai on 2021/7/28.
//

#import <RongIMLibCore/RongIMLibCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCUserInfo (Coding)

+ (NSDictionary *)encode:(RCUserInfo *)userInfo;
+ (RCUserInfo *)decode:(NSDictionary *)userInfo;

+ (NSArray<NSDictionary *> *)encodeContentOf:(NSArray<RCUserInfo *> *)userInfos;
+ (NSArray<RCUserInfo *> *)decodeContentOf:(NSArray<NSDictionary *> *)userInfos;

@end

NS_ASSUME_NONNULL_END
