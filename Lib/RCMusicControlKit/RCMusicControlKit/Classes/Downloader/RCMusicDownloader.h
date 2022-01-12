//
//  RCMusicDownloader.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/10.
//

#import <Foundation/Foundation.h>
#import "RCMusicInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMusicDownloader : NSObject


/// 下载音乐
/// @param info  音乐信息
/// @param downloadProgressBlock  下载进度回调
/// @param downloadFinish  下载完成回调
/// @param completionHandler  任务结束回调
+ (nullable NSURLSessionDownloadTask *)downloadWithInfo:(id<RCMusicInfo>)info
                                     progress:(void (^ _Nullable)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                               downloadFinish:(void(^ _Nullable)(NSString * _Nullable filePath, NSURLResponse * _Nullable response))downloadFinish
                            completionHandler:(void (^ _Nullable)(NSURLResponse * _Nullable response, NSString * _Nullable filePath, NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
