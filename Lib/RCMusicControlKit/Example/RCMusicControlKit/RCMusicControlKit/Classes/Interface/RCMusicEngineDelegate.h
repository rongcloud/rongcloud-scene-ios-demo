//
//  RCMusicEngineDelegate.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/10.
//

#import <Foundation/Foundation.h>
#import "RCMusicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RCMusicEngineDelegate <NSObject>
@required
/// 下载歌曲资源文件
/// @param music 歌曲信息
/// @param completion 返回处理状态
- (void)downloadedMusic:(id<RCMusicInfo>)music completion:(void(^)(BOOL success))completion;

/// 删除歌曲
/// @param music 歌曲信息
/// @param completion 返回处理状态
- (void)deleteMusic:(id<RCMusicInfo>)music completion:(void(^)(BOOL success))completion;


/// 置顶歌曲
/// @param music1 当前播放的歌曲
/// @param music2 被置顶的歌曲
/// @param completion 返回处理状态
- (void)topMusic:(nullable id<RCMusicInfo>)music1 withMusic:(id<RCMusicInfo>)music2 completion:(void(^)(BOOL success))completion;

@optional
/// 初始化
/// 设置 Engine delegate 时调用该方法
- (void)delegateInitialized;
@end

NS_ASSUME_NONNULL_END
