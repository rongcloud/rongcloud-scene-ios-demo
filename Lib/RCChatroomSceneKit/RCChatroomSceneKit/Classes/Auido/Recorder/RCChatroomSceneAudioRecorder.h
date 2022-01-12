//
//  RCChatroomSceneAudioRecorder.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCChatroomSceneAudioRecorder : NSObject

+ (instancetype)defaultRecorder;
+ (instancetype)HQRecorder;

- (BOOL)start;
- (void)stop:(void(^)(NSData *data, NSTimeInterval duration))completion;

@end

NS_ASSUME_NONNULL_END
