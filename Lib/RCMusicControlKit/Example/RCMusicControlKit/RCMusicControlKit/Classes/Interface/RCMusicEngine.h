//
//  RCMusicEngine.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/10.
//

#import <UIKit/UIKit.h>
#import "RCMusicPlayer.h"
#import "RCMusicEngineDelegate.h"
#import "RCMusicEngineDataSource.h"

typedef NS_ENUM(NSUInteger, RCMusicMixingState) {
    /*!
     播放中（或混音中）
     */
    RCMusicMixingStatePlaying,
    /*!
     暂停中
     */
    RCMusicMixingStatePause,
    /*!
     停止
     */
    RCMusicMixingStateStop
};

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicEngine : NSObject
//播放器
@property (nonatomic, weak) id<RCMusicPlayer> player;
//音频的增删改操作
@property (nonatomic, weak) id<RCMusicEngineDelegate> delegate;
//音频数据操作，播放列表，线上音乐列表等数据的获取
@property (nonatomic, weak) id<RCMusicEngineDataSource> dataSource;
//音乐信息气泡 showMusicInfoBubble == NO 时为nil
//Engine不持有该View每次获取的对象不同
@property (class, nonatomic, readonly, nullable) UIView *musicInfoBubbleView;

+ (instancetype)shareInstance;
//TODO
- (void)initWithAppId:(nonnull NSString *)appId
           serverCode:(nonnull NSString *)serverCode
             clientId:(nonnull NSString *)clientId
              version:(nonnull NSString *)version
              success:(void (^)(id response))success
                 fail:(void (^)(NSError *error))failure;

///展示 MusicControl
/// @param viewController 发起的页面vc
/// @param completion 跳转结束之后的callback
- (void)showInViewController:(nonnull UIViewController *)viewController completion:(void (^_Nullable)(void))completion;

///展示 同步播放器状态
/// @param state 播放器状态
/// RCMusicMixingStatePlaying, RCMusicMixingStatePause, RCMusicMixingStateStop
- (void)asyncMixingState:(RCMusicMixingState)state;

@end

NS_ASSUME_NONNULL_END
