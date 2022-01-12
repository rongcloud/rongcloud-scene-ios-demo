//
//  RCChatroomSceneAudioPlayer.h
//  Alamofire
//
//  Created by shaoshuai on 2021/10/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCChatroomSceneAudioPlayerDelegate <NSObject>

- (void)didBegin;
- (void)didEnd;

@end

@interface RCChatroomSceneAudioPlayer : NSObject

+ (instancetype)shared;

- (void)play:(NSURL *)url delegate:(id<RCChatroomSceneAudioPlayerDelegate>)delegate;

- (void)stop;

- (BOOL)isPlaying;

- (NSURL *)currentURL;

@end

NS_ASSUME_NONNULL_END
