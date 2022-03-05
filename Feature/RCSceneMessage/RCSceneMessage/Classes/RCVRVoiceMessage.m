//
//  RCChatroomVoiceMessage.m
//  RCE
//
//  Created by shaoshuai on 2021/8/3.
//

#import "RCVRVoiceMessage.h"

@implementation RCVRVoiceMessage

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (_userId) [dataDict setObject:_userId forKey:@"_userId"];
    if (_userName) [dataDict setObject:_userName forKey:@"_userName"];
    if (_path) [dataDict setObject:_path forKey:@"_path"];
    if (_duration > 0) [dataDict setObject:@(_duration) forKey:@"_duration"];
    return [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    _userId = json[@"_userId"];
    _userName = json[@"_userName"];
    _path = json[@"_path"];
    _duration = [json[@"_duration"] integerValue];
}

+ (NSString *)getObjectName {
    return @"RC:VRVoiceMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end
