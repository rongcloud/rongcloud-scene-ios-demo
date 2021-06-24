
#import "RCChatroomEnter.h"

@implementation RCChatroomEnter

- (NSData *)encode {
    NSMutableDictionary *multableDict = [NSMutableDictionary dictionary];
    if (self.userId) {
        [multableDict setObject:self.userId forKey:@"userId"];
    } else {
        [multableDict setObject:@"" forKey:@"userId"];
    }
    if (self.userName) {
        [multableDict setObject:self.userName forKey:@"userName"];
    } else {
        [multableDict setObject:@"" forKey:@"userName"];
    }
    return [NSJSONSerialization dataWithJSONObject:multableDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    self.userId = [json objectForKey:@"userId"];
    self.userName = [json objectForKey:@"userName"];
}

+ (NSString *)getObjectName {
  return @"RC:Chatroom:Enter";
}

- (NSArray<NSString *> *)getSearchableWords {
  return nil;
}

+ (RCMessagePersistent)persistentFlag {
  return 3;
}

@end

