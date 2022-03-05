//
//  RCUserInfo+Coding.m
//  ChatRoomScene
//
//  Created by shaoshuai on 2021/7/28.
//

#import "RCUserInfo+Coding.h"

@implementation RCUserInfo (Coding)

+ (NSDictionary *)encode:(RCUserInfo *)userInfo {
    if (userInfo == nil) return @{};
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (userInfo.userId) [dict setObject:userInfo.userId forKey:@"id"];
    if (userInfo.name) [dict setObject:userInfo.name forKey:@"name"];
    if (userInfo.portraitUri) [dict setObject:userInfo.portraitUri forKey:@"portrait"];
    return dict;
}

+ (RCUserInfo *)decode:(NSDictionary *)userInfo {
    return [[RCUserInfo alloc] initWithUserId:userInfo[@"id"]
                                         name:userInfo[@"name"]
                                     portrait:userInfo[@"portrait"]];
}

+ (NSArray<NSDictionary *> *)encodeContentOf:(NSArray<RCUserInfo *> *)userInfos {
    NSMutableArray *array = [NSMutableArray array];
    for (RCUserInfo *userInfo in userInfos) {
        [array addObject:[RCUserInfo encode:userInfo]];
    }
    return array;
}

+ (NSArray<RCUserInfo *> *)decodeContentOf:(NSArray<NSDictionary *> *)userInfos {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *userInfo in userInfos) {
        [array addObject:[RCUserInfo decode:userInfo]];
    }
    return array;
}

@end
