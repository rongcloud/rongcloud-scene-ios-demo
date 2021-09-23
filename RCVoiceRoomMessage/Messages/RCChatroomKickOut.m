
#import "RCChatroomKickOut.h"

@implementation RCChatroomKickOut

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
    if (self.targetId) {
        [mutableDict setObject:self.targetId forKey:@"targetId"];
    } else {
        [mutableDict setObject:@"" forKey:@"targetId"];
    }
    if (self.targetName) {
        [mutableDict setObject:self.targetName forKey:@"targetName"];
    } else {
        [mutableDict setObject:@"" forKey:@"targetName"];
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
    self.targetId = [json objectForKey:@"targetId"];
    self.targetName = [json objectForKey:@"targetName"];
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:KickOut";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return MessagePersistent_NONE;
}

@end

