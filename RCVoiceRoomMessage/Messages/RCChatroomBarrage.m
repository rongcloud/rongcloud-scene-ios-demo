
#import "RCChatroomBarrage.h"

@implementation RCChatroomBarrage

- (NSData *)encode {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    if (self.userId) {
        [mutableDict setObject:self.userId forKey:@"userId"];
    } else {
        [mutableDict setObject:@"" forKey:@"userId"];
    }
    if (self.userName) {
        [mutableDict setObject:self.userName forKey:@"userName"];
    } else {
        [mutableDict setObject:@"" forKey:@"userName"];
    }
    if (self.content) {
        [mutableDict setObject:self.content forKey:@"content"];
    } else {
        [mutableDict setObject:@"" forKey:@"content"];
    }
    return [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    self.userId = [json objectForKey:@"userId"];
    self.userName = [json objectForKey:@"userName"];
    self.content = [json objectForKey:@"content"];
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Barrage";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_NONE;
}

@end

