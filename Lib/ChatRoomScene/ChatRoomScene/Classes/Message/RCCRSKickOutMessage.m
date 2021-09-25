//
//  RCMCKickOutMessage.m
//  RCE
//
//  Created by shaoshuai on 2021/7/15.
//

#import "RCCRSKickOutMessage.h"
#import "RCCRSReceiverProtocol.h"
#import "RCCRSHandlerProtocol.h"
#import "RCUserInfo+Coding.h"

@implementation RCCRSKickOutMessage

- (NSData *)encode {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    if (_userInfo) [mutableDict setObject:[RCUserInfo encode:_userInfo] forKey:@"_userInfo"];
    if (_targetUserInfos) [mutableDict setObject:[RCUserInfo encodeContentOf:_targetUserInfos] forKey:@"_targetUserInfos"];
    if (self.extra) [mutableDict setObject:self.extra forKey:@"_extra"];
    return [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    _userInfo = [RCUserInfo decode:[json objectForKey:@"_userInfo"]];
    _targetUserInfos = [RCUserInfo decodeContentOf:[json objectForKey:@"_targetUserInfos"]];
    self.extra = [json objectForKey:@"_extra"];
}

+ (NSString *)getObjectName {
  return @"RC:CRSKickOutMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_NONE;
}

@end

@interface RCCRSKickOutMessage (handler) <RCCRSHandlerProtocol>

@end

@implementation RCCRSKickOutMessage (handler)

- (void)handleMessage:(RCMessage *)message toReceiver:(id<RCCRSReceiverProtocol>)receiver {
    [receiver kickOutMessageDidReceive:self];
}

@end
