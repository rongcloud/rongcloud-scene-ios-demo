//
//  RCChatroomMessage.m
//  RCE
//
//  Created by shaoshuai on 2021/5/25.
//

#import "RCChatroomMessage.h"
#import <objc/runtime.h>

@implementation RCChatroomMessage

- (NSData *)encode {
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        const char *ivar_name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
        id value = [self valueForKey:key];
        if (value == nil) continue;
        [mutableDict setObject:value forKey:key];
    }
    return [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
}

- (void)decodeWithData:(NSData *)data {
    if (data == nil) return;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        const char *ivar_name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
        id value = dictionary[key];
        if (value == nil) continue;
        [self setValue:value forKey:key];
    }
}

+ (NSString *)getObjectName {
    return @"RC:Chatroom:Base";
}

- (NSArray<NSString *> *)getSearchableWords {
    return nil;
}

+ (RCMessagePersistent)persistentFlag {
    return 3;
}

@end
