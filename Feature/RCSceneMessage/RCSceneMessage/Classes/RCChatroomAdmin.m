
#import "RCChatroomAdmin.h"

@implementation RCChatroomAdmin

- (NSData *)encode {
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    if (self.userId) {
        [dataDict setObject:self.userId forKey:@"userId"];
    } else {
        [dataDict setObject:@"" forKey:@"userId"];
    }
    if (self.userName) {
        [dataDict setObject:self.userName forKey:@"userName"];
    } else {
        [dataDict setObject:@"" forKey:@"userName"];
    }
    [dataDict setObject:@(self.isAdmin) forKey:@"isAdmin"];
    return [NSJSONSerialization dataWithJSONObject:dataDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    NSDictionary *json = [[NSDictionary alloc] initWithDictionary:dictionary];
    if (json == nil) return;
    self.userId = json[@"userId"];
    self.userName = json[@"userName"];
    self.isAdmin = [json[@"isAdmin"] boolValue];
}

+ (NSString *)getObjectName {
    return @"RC:Chatroom:Admin";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end

