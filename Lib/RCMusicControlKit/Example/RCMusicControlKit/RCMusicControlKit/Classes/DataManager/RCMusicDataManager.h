//
//  RCMusicDataManager.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import <UIKit/UIKit.h>
#import "RCMusicInfo.h"
@class RCMusicData;
@class RCMusicChannelData;
@class RCMusicSheetRecord;
@class RCMusicData;
@class RCMusicRecord;
@class RCMusicDetail;
NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSString *const RCMusicLocalDataChangedNotification;

@interface RCMusicDataManager : NSObject

+ (instancetype)shareInstance;

#pragma mark -LOCAL DATA
//本地音乐列表
+ (NSArray<RCMusicInfo> *)allMusics;

/// 存储音乐到本地
/// @param music  歌曲信息
/// @param srcPath 当前路径
/// @param fileName 文件名
+ (BOOL)storageMusic:(id<RCMusicInfo>)music srcPath:(NSString *)srcPath fileName:(NSString *)fileName;

/// 删除音乐
/// @param music 歌曲信息
+ (BOOL)deleteMusic:(id<RCMusicInfo>)music;


/// 更新本地歌曲顺序
/// @param music1  正在播放的音乐
/// @param music2  将要置顶的音乐
+ (BOOL)topMusic:(nullable id<RCMusicInfo>)music1 withMusic:(id<RCMusicInfo>)music2;

/// 本地是否存在音乐
/// @param musicId 音乐id
+ (BOOL)musicIsExist:(NSString *)musicId;


/// 移动文件到指定位置
/// @param srcPath 源文件位置
/// @param dstPath 目标位置
+ (BOOL)moveFile:(NSString *)srcPath to:(NSString *)dstPath;

+ (BOOL)removeFile:(NSString *)path;

#pragma mark -REMOTE DATA
/// 获取电台
+ (void)fetchChannelWithCompletion:(void (^)(NSArray<RCMusicChannelData *> * _Nullable channels, NSError *error))completion;

/// 获取歌单列表
/// @param channelId 电台ID
+ (void)fetchCategoriesWithChannelId:(NSString *)channelId completion:(void (^)(NSArray<RCMusicSheetRecord *> * _Nullable sheets, NSError *error))completion;

/// 获取歌单歌曲列表
/// @param sheetId 歌单ID
/// @param refresh 是否刷新
+ (void)fetchMusicsWithSheetId:(NSString *)sheetId refresh:(BOOL)refresh completion:(void (^)(NSArray<RCMusicRecord *> * _Nullable musics, NSError *error))completion;

/// 获取音乐HQ播放信息
/// @param musicId 音乐id
/// @param audioFormat 文件编码,默认mp3,  mp3 / aac
/// @param audioRate 音质，音乐播放时的比特率，默认320, 320 / 128
/// @param success 成功回调
/// @param failure 失败回调
+ (void)trafficHQListenWithMusicId:(nonnull NSString *)musicId
                      audioFormat:(nullable NSString *)audioFormat
                        audioRate:(nullable NSString *)audioRate
                          success:(void (^)(RCMusicDetail  * _Nullable response))success
                             fail:(void (^)(NSError * _Nullable error))failure;

+ (void)searchMusicWithKeyWord:(nonnull NSString *)keyword completion:(void (^)(NSArray<RCMusicRecord *> * _Nullable musics, NSError *error))completion;
/// 下载音乐
/// @param music 音乐信息
/// @param downloadProgressBlock 进度回调
/// @param downloadFinish 下载完成回调
/// @param completionHandler 请求完成回调
+ (NSURLSessionDownloadTask *)downloadWithMusic:(id<RCMusicInfo>)music
                                       progress:(void (^)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                                 downloadFinish:(void(^)(id <RCMusicInfo> _Nullable music))downloadFinish
                              completionHandler:(void (^)(NSURLResponse * _Nullable response, NSString * _Nullable filePath, NSError * _Nullable error))completionHandler;


/// 添加本地数据
/// @param rootViewController 发起的ViewController
+ (void)addLocalMusic:(UIViewController *)rootViewController;
@end

NS_ASSUME_NONNULL_END

