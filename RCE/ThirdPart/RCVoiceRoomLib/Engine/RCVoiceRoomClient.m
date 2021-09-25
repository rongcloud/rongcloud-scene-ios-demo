//
//  RCVoiceRoomClient.m
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

#import "RCVoiceRoomClient.h"
#import "RCIMKitReceiver.h"
#import "RCIMLibReceiver.h"

@implementation RCVoiceRoomClient

+ (id<RCVoiceRoomClientProtocol>)client {
    static dispatch_once_t onceToken;
    static id<RCVoiceRoomClientProtocol> client;
    dispatch_once(&onceToken, ^{
        if (NSClassFromString(@"RCIM")) {
            client = [[RCIMKitReceiver alloc] init];
        } else {
            client = [[RCIMLibReceiver alloc] init];
        }
    });
    return client;
}

@end
