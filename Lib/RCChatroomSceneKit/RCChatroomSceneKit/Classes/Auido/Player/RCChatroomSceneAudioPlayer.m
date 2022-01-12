//
//  RCChatroomSceneAudioPlayer.m
//  Alamofire
//
//  Created by shaoshuai on 2021/10/28.
//

#import <AVFoundation/AVFoundation.h>

#import "RCChatroomSceneAudioPlayer.h"

@interface RCChatroomSceneAudioPlayer () <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSURLSessionTask *downloadTask;

@property (nonatomic, weak) id<RCChatroomSceneAudioPlayerDelegate> delegate;

@end

@implementation RCChatroomSceneAudioPlayer

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static RCChatroomSceneAudioPlayer *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RCChatroomSceneAudioPlayer alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVAudioSessionInterruptionNotification:) name:AVAudioSessionInterruptionNotification object:nil];
    }
    return self;
}

- (void)play:(NSURL *)url delegate:(id<RCChatroomSceneAudioPlayerDelegate>)delegate {
    if ([self.currentURL isEqual:url]) {
        self.delegate = delegate;
        if (![self isPlaying]) {
            [self.player play];
        }
        return;
    }
    
    [self stop];
    
    self.delegate = delegate;
    self.URL = url;
    
    if ([url isFileURL] || url.scheme == nil) {
        [self play:url];
    } else {
        __weak typeof(self) weakSelf = self;
        [self download:url completion:^(NSURL *localURL) {
            [weakSelf play:localURL];
        }];
    }
}

- (void)play:(NSURL *)localURL {
    NSError *error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:localURL error:&error];
    if (error) {
        if ([self.delegate respondsToSelector:@selector(didEnd)]) {
            [self.delegate didEnd];
        }
        return;
    }
    self.player.delegate = self;
    [self.player play];
}

- (void)stop {
    if ([self isPlaying]) {
        if ([self.delegate respondsToSelector:@selector(didEnd)]) {
            [self.delegate didEnd];
        }
        [self.player pause];
    }
}

- (BOOL)isPlaying {
    if (self.player == nil) return NO;
    return self.player.isPlaying;
}

- (NSURL *)currentURL {
    return self.player.url;
}

#pragma mark - AVAudioPlayerDelegate -

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if ([self.delegate respondsToSelector:@selector(didEnd)]) {
        [self.delegate didEnd];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(didEnd)]) {
        [self.delegate didEnd];
    }
}

#pragma mark - -

- (void)AVAudioSessionInterruptionNotification:(NSNotification *)notificaiton {
    NSLog(@"%@", notificaiton.userInfo);
    AVAudioSessionInterruptionType type = [notificaiton.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self.player pause];
    } else {
        [self.player play];
    }
}

#pragma mark - Download -

- (void)download:(NSURL *)url completion:(void(^)(NSURL *))completion {
    if (self.downloadTask && self.downloadTask.state != NSURLSessionTaskStateCompleted) {
        [self.downloadTask cancel];
    }
    NSURLSession *session = [NSURLSession sharedSession];
    self.downloadTask = [session downloadTaskWithURL:url
                                   completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            completion(location);
        }
    }];
    [self.downloadTask resume];
}

@end
