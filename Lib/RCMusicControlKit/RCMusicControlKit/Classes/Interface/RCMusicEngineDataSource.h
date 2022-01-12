//
//  RCMusicEngineDataSource.h
//  RCE
//
//  Created by xuefeng on 2021/11/24.
//

#import <UIKit/UIKit.h>
#import "RCMusicInfo.h"
#import "RCMusicCategoryInfo.h"
#import "RCMusicEffectInfo.h"


typedef NSString *RCMusicToolBarKey NS_TYPED_EXTENSIBLE_ENUM;

static RCMusicToolBarKey const _Nullable RCMusicToolBarKeyRoomList = @"RCMusicToolBarKeyRoomList";
static RCMusicToolBarKey const _Nullable RCMusicAppearanceOnlineList = @"RCMusicAppearanceOnlineList";
static RCMusicToolBarKey const _Nullable RCMusicAppearanceMusicControl = @"RCMusicAppearanceMusicControl";
static RCMusicToolBarKey const _Nullable RCMusicAppearanceAudioEffect = @"RCMusicAppearanceAudioEffect";

NS_ASSUME_NONNULL_BEGIN

@protocol RCMusicEngineDataSource <NSObject>
@required
/// 获取歌曲类别
/// @param completion RCMusicCategoryInfo 类别信息字段协议
- (void)fetchCategories:(void(^)(NSArray<RCMusicCategoryInfo> * _Nullable categories))completion;

/// 获取歌曲列表
/// @param categoryId 类别id
/// @param completion RCMusicInfo 歌曲信息字段协议
- (void)fetchOnlineMusicsByCategoryId:(NSString *)categoryId
                           completion:(void(^)(NSArray<RCMusicInfo> * _Nullable musics))completion;

/// 获取收藏的歌曲
/// @param completion 返回歌曲信息列表
- (void)fetchCollectMusics:(void(^)(NSArray<RCMusicInfo> * _Nullable musics))completion;


/// 获取歌曲详细信息
/// @param info  歌曲信息model，一部分字段会通过本接口补全返回全部信息的info model
- (void)fetchMusicDetailWithInfo:(id<RCMusicInfo> _Nonnull)info
                      completion:(void(^)(id<RCMusicInfo> _Nullable music))completion;
/// 通过关键字搜索歌曲
/// @param keyWord 关键字
/// @param completion 歌曲信息列表
- (void)fetchSearchResultWithKeyWord:(NSString *)keyWord
                          completion:(void(^)(NSArray<RCMusicInfo> * _Nullable musics))completion;


/// 歌曲是否本地已经下载
/// @param info  歌曲信息
- (BOOL)musicIsExist:(id<RCMusicInfo>)info;

@optional
/// 初始化
/// 设置 Engine DataSource 时调用该方法
- (void)dataSourceInitialized;

/// 获取特效数据源
/// @param completion RCMusicEffectInfo 数据源数据协议
- (void)fetchSoundEffectsWithCompletion:(void(^)(NSArray<RCMusicEffectInfo> * _Nullable effects))completion;


/// 添加本地文件夹数据，
/// UIDocumentPickerViewController
/// @param rootViewController  跳转发起的页面
- (void)addLocalMusic:(UIViewController *)rootViewController;

//download TODO
@end

NS_ASSUME_NONNULL_END
