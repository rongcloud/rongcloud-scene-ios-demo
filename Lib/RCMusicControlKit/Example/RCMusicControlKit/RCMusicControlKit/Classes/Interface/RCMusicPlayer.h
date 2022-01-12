//
//  RCMusicPlayer.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/10.
//

#import <Foundation/Foundation.h>
#import "RCMusicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCMusicPlayer <NSObject>
@property (nonatomic, strong, nullable) id<RCMusicInfo> currentPlayingMusic;
@required
//本地音量
- (NSInteger)localVolume;
- (void)setLocalVolume:(NSInteger)volume;
//远端音量
- (NSInteger)remoteVolume;
- (void)setRemoteVolume:(NSInteger)volume;
//麦克风音量
- (NSInteger)micVolume;
- (void)setMicVolume:(NSInteger)volume;
//耳返
- (void)setEarOpenMonitoring:(BOOL)on;
//开始混音
- (BOOL)startMixingWithMusicInfo:(id<RCMusicInfo>)info;
//暂停混音
- (BOOL)stopMixingWithMusicInfo:(nullable id<RCMusicInfo>)info;
//播放音效
- (void)playEffect:(NSInteger)soundId filePath:(NSString *)filePath;

@optional
/// 初始化
/// 设置 Engine player 时调用该方法
- (void)playerInitialized;
@end

NS_ASSUME_NONNULL_END
