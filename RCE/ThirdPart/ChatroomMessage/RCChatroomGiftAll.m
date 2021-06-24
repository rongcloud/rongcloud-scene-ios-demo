
#import "RCChatroomGiftAll.h"

@implementation RCChatroomGiftAll

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
    if (self.giftId) {
        [mutableDict setObject:self.giftId forKey:@"giftId"];
    } else {
        [mutableDict setObject:@"" forKey:@"giftId"];
    }
    if (self.giftName) {
        [mutableDict setObject:self.giftName forKey:@"giftName"];
    } else {
        [mutableDict setObject:@"" forKey:@"giftName"];
    }
    [mutableDict setObject:@(self.number) forKey:@"number"];
    [mutableDict setObject:@(self.price) forKey:@"price"];
    return [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    self.userId = [json objectForKey:@"userId"];
    self.userName = [json objectForKey:@"userName"];
    self.giftId = [json objectForKey:@"giftId"];
    self.giftName = [json objectForKey:@"giftName"];
    self.number = [[json objectForKey:@"number"] intValue];
    self.price = [[json objectForKey:@"price"] intValue];
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:GiftAll";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end

