//
//  RCMusicEnginePlayerMediator.h
//  RCE
//
//  Created by xuefeng on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import "RCMusicInfo.h"
#import "RCMusicPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicEnginePlayerHifiveImpl : NSObject<RCMusicPlayer>
@property (nonatomic, strong, nullable) id<RCMusicInfo> currentPlayingMusic;
+ (instancetype)instance;
@end

NS_ASSUME_NONNULL_END
