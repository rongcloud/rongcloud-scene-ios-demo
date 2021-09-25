//
//  RCMessageContentGift.m
//  RCE
//
//  Created by shaoshuai on 2021/7/14.
//

#import "RCCRSGiftMessage.h"
#import "RCCRSGiftModel.h"
#import "RCCRSReceiverProtocol.h"
#import "RCCRSHandlerProtocol.h"
#import "RCUserInfo+Coding.h"

@implementation RCCRSGiftMessage

- (NSData *)encode {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    if (_userInfo) [mutableDict setObject:[RCUserInfo encode:_userInfo] forKey:@"_userInfo"];
    if (_targetUserInfos) [mutableDict setObject:[RCUserInfo encodeContentOf:_targetUserInfos] forKey:@"_targetUserInfos"];
    if (_gift) [mutableDict setObject:[RCCRSGiftModel encode:_gift] forKey:@"_gift"];
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
    _gift = [RCCRSGiftModel decode:[json objectForKey:@"_gift"]];
    self.extra = [json objectForKey:@"_extra"];
}

+ (NSString *)getObjectName {
  return @"RC:CRSGiftMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_NONE;
}

@end

@interface RCCRSGiftMessage (handler) <RCCRSHandlerProtocol>

@end

@implementation RCCRSGiftMessage (handler)

- (void)handleMessage:(RCMessage *)message toReceiver:(id<RCCRSReceiverProtocol>)receiver {
    [receiver giftMessageDidReceive:self];
}

@end
