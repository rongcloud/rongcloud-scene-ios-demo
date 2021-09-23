
#import "RCChatroomFollow.h"

#import "RCUserInfo+Coding.h"

@implementation RCChatroomFollow

- (NSData *)encode {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setObject:[RCUserInfo encode:_userInfo] forKey:@"_userInfo"];
    [mutableDict setObject:[RCUserInfo encode:_targetUserInfo] forKey:@"_targetUserInfo"];
    return [NSJSONSerialization dataWithJSONObject:mutableDict
                                           options:kNilOptions
                                             error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    id result = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions
                                                  error:nil];
    if (![result isKindOfClass:[NSDictionary class]]) return;
    NSDictionary *dict = (NSDictionary *)result;
    _userInfo = [RCUserInfo decode:dict[@"_userInfo"]];
    _targetUserInfo = [RCUserInfo decode:dict[@"_targetUserInfo"]];
}

+ (NSString *)getObjectName {
    return @"RC:VRFollowMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end

