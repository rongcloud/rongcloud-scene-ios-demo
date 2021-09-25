//
//  RCVoiceRoomRefreshMessage.m
//  RCE
//
//  Created by 叶孤城 on 2021/5/20.
//

#import "RCVoiceRoomRefreshMessage.h"

@implementation RCVoiceRoomRefreshMessage

- (NSData *)encode {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.content != nil) {
        dict[@"content"] = self.content;
    }
    if (self.name != nil) {
        dict[@"name"] = self.name;
    }
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingFragmentsAllowed error:nil];
}

- (void)decodeWithData:(NSData *)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.content = dict[@"content"];
    self.name = dict[@"name"];
}

+ (NSString *)getObjectName {
    return @"RC:VRLRefreshMsg";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return MessagePersistent_NONE;
}

@end
