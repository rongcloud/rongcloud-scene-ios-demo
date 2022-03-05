
#import "RCChatroomLike.h"

@implementation RCChatroomLike

- (NSData *)encode {
    return [NSJSONSerialization dataWithJSONObject:@{} options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Like";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_NONE;
}

@end

