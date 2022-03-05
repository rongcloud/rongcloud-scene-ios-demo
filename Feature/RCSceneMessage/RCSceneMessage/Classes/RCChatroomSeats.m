
#import "RCChatroomSeats.h"

@implementation RCChatroomSeats

- (NSData *)encode {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setObject:@(self.count) forKey:@"count"];
    return [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    self.count = [[json objectForKey:@"count"] intValue];
}

+ (NSString *)getObjectName {
    return @"RC:Chatroom:Seats";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end

