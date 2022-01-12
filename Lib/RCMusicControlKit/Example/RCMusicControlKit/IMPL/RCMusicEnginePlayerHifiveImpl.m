//
//  RCMusicEnginePlayerMediator.m
//  RCE
//
//  Created by xuefeng on 2021/11/25.
//

#import "RCMusicEnginePlayerHifiveImpl.h"
#import <RongRTCLib/RongRTCLib.h>
#import "RCMusicDataPath.h"
#import "RCMusicEngine.h"

@interface RCMusicEnginePlayerHifiveImpl ()<RCRTCAudioMixerAudioPlayDelegate>

@end

@implementation RCMusicEnginePlayerHifiveImpl

- (void)dealloc {
    
}

+ (instancetype)instance {
    static RCMusicEnginePlayerHifiveImpl *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RCMusicEnginePlayerHifiveImpl alloc] init];
        [RCRTCAudioMixer sharedInstance].delegate = instance;
    });
    return instance;
}

- (NSInteger)localVolume {
    return [RCRTCAudioMixer sharedInstance].playingVolume;
}

- (void)setLocalVolume:(NSInteger)volume {
    [RCRTCAudioMixer sharedInstance].playingVolume = volume;
}

- (NSInteger)remoteVolume {
    return [RCRTCAudioMixer sharedInstance].mixingVolume;
}

- (void)setRemoteVolume:(NSInteger)volume {
    [RCRTCAudioMixer sharedInstance].mixingVolume = volume;
}

- (NSInteger)micVolume {
    return [[RCRTCEngine sharedInstance] defaultAudioStream].recordingVolume;
}

- (void)setMicVolume:(NSInteger)volume {
    [[RCRTCEngine sharedInstance] defaultAudioStream].recordingVolume = volume;
}

- (void)setEarOpenMonitoring:(BOOL)on {
    [[RCRTCEngine sharedInstance].audioEffectManager enableInEarMonitoring:on];
}

- (BOOL)startMixingWithMusicInfo:(id<RCMusicInfo>)info {
    self.currentPlayingMusic = info;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[RCMusicDataPath musicsDir:[RCMusicDataPath document]],info.musicId];
    BOOL success = [[RCRTCAudioMixer sharedInstance] startMixingWithURL:[NSURL fileURLWithPath:filePath] playback:YES mixerMode:RCRTCMixerModeMixing loopCount:1];
    return success;
}

- (BOOL)stopMixingWithMusicInfo:(nullable id<RCMusicInfo>)info {
    self.currentPlayingMusic = nil;
    return [[RCRTCAudioMixer sharedInstance] stop];
}

- (void)playEffect:(NSInteger)soundId filePath:(NSString *)filePath {
    [[RCRTCEngine sharedInstance].audioEffectManager stopAllEffects];
    [[RCRTCEngine sharedInstance].audioEffectManager playEffect:soundId filePath:filePath loopCount:1 publish:YES];
}

- (void)didAudioMixingStateChanged:(RCRTCAudioMixingState)mixingState reason:(RCRTCAudioMixingReason)mixingReason {
    if (mixingState == RCRTCMixingStateStop) {
        self.currentPlayingMusic = nil;
    }
    [[RCMusicEngine shareInstance] asyncMixingState:(RCMusicMixingState)mixingState];
}

- (void)didReportPlayingProgress:(float)progress {
    
}
@end
