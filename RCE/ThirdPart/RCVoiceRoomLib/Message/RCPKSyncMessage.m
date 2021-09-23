//
//  RCPKSyncMessage.m
//  RCE
//
//  Created by 叶孤城 on 2021/8/17.
//

#import "RCPKSyncMessage.h"

@implementation RCPKSyncMessage

- (NSData *)encode {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.jsonString != nil) {
        dict[@"jsonString"] = self.extra;
    }
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.jsonString = dict[@"jsonString"];
}

+ (NSString *)getObjectName {
    return @"RC:PKSyncMessage";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end
