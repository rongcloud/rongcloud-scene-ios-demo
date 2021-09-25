//
//  RCVoiceRoomClient.h
//  RCE
//
//  Created by shaoshuai on 2021/6/21.
//

#import <RongRTCLib/RongRTCLib.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCVoiceRoomClientProtocol;

@interface RCVoiceRoomClient : NSObject

+ (id<RCVoiceRoomClientProtocol>)client;

@end

NS_ASSUME_NONNULL_END
