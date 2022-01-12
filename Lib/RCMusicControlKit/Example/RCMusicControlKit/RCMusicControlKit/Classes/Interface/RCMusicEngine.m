//
//  RCMusicEngine.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/10.
//

#import "RCMusicEngine.h"
#import "HFOpenApiManager.h"
#import "RCMusicContainerViewController.h"
#import "RCMusicDefine.h"
#import "RCMusicInfoBubbleView.h"
#import "RCMusicDataManager.h"

@interface RCMusicEngine ()
@property (nonatomic, weak) UIViewController *targetViewController;
@end

@implementation RCMusicEngine

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static RCMusicEngine *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RCMusicEngine alloc] init];
        [RCMusicDataManager shareInstance];
    });
    return instance;
}

- (void)initWithAppId:(NSString *)appId
           serverCode:(NSString *)serverCode
             clientId:(NSString *)clientId
              version:(NSString *)version
              success:(void (^)(id response))success
                 fail:(void (^)(NSError *error))failure {
    [[HFOpenApiManager shared] registerAppWithAppId:appId serverCode:serverCode clientId:clientId version:version success:success fail:failure];
}

- (void)setPlayer:(id<RCMusicPlayer>)player {
    _player = player;
    if (player && [player respondsToSelector:@selector(playerInitialized)]) {
        [player playerInitialized];
    }
}

- (void)setDelegate:(id<RCMusicEngineDelegate>)delegate {
    _delegate = delegate;
    if (delegate && [delegate respondsToSelector:@selector(delegateInitialized)]) {
        [delegate delegateInitialized];
    }
}

- (void)setDataSource:(id<RCMusicEngineDataSource>)dataSource {
    _dataSource = dataSource;
    if (dataSource && [dataSource respondsToSelector:@selector(dataSourceInitialized)]) {
        [dataSource dataSourceInitialized];
    }
}

- (void)showInViewController:(nonnull UIViewController *)viewController completion:(void (^)(void))completion {
    self.targetViewController = viewController;
    if (viewController != nil) {
        RCMusicContainerViewController *container = [[RCMusicContainerViewController alloc] init];
        [viewController presentViewController:container animated:YES completion:completion];
    }
}

- (void)asyncMixingState:(RCMusicMixingState)state {
    NSDictionary *info;
    if (self.player.currentPlayingMusic) {
        info = @{@"state":@(state),@"musicInfo":self.player.currentPlayingMusic};
    } else {
        info = @{@"state":@(state)};
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RCMusicAsyncMixStateNotification object:info];
}


+ (UIView *)musicInfoBubbleView {
    RCMusicInfoBubbleView *bubble = [[RCMusicInfoBubbleView alloc] init];
    return bubble;
}
@end
