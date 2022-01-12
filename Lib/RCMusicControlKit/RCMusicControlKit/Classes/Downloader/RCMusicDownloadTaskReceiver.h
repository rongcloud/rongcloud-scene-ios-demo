//
//  RCMusicDownloadTaskReceiver.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import <Foundation/Foundation.h>

typedef void (^RCMusicSessionDownloadTaskProgressBlock)(NSProgress * _Nullable progress);
typedef void (^RCMusicSessionDownloadTaskDidFinishDownloadingBlock)(NSString * _Nullable filePath, NSURLResponse * _Nullable response);
typedef void (^RCMusicSessionTaskCompletionHandler)(NSURLResponse * _Nullable response, NSString * _Nullable filePath, NSError * _Nonnull error);

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicDownloadTaskReceiver : NSObject <NSURLSessionTaskDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>
//进度回调
@property (nonatomic, copy, nullable) RCMusicSessionDownloadTaskProgressBlock downloadProgressBlock;
//任务结束回调
@property (nonatomic, copy, nullable) RCMusicSessionTaskCompletionHandler completionHandler;
//下载完成回调
@property (nonatomic, copy, nullable) RCMusicSessionDownloadTaskDidFinishDownloadingBlock downloadTaskDidFinishDownloading;
@end

NS_ASSUME_NONNULL_END
