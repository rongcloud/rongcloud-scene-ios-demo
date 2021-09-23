//
//  RCMCLikeMessage.m
//  RCE
//
//  Created by shaoshuai on 2021/7/15.
//

#import "RCCRSLikeMessage.h"

#import "RCCRSHandlerProtocol.h"
#import "RCCRSReceiverProtocol.h"

@implementation RCCRSLikeMessage

- (NSData *)encode {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    if (self.extra) [mutableDict setObject:self.extra forKey:@"_extra"];
    return [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    _count = [[json objectForKey:@"_count"] intValue];
    self.extra = [json objectForKey:@"_extra"];
}

+ (NSString *)getObjectName {
  return @"RC:CRSLikeMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_NONE;
}

@end

@interface RCCRSLikeMessage (handler) <RCCRSHandlerProtocol>

@end

@implementation RCCRSLikeMessage (handler)

- (void)handleMessage:(RCMessage *)message toReceiver:(id<RCCRSReceiverProtocol>)receiver {
    [receiver likeMessageDidReceive:self];
}

@end
