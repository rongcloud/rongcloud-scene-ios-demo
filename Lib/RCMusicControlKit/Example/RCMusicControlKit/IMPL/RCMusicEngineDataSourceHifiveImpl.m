//
//  RCMusicEngineDataSourceMediator.m
//  RCE
//
//  Created by xuefeng on 2021/11/24.
//

#import "RCMusicEngineDataSourceHifiveImpl.h"
#import "RCMusicDataManager.h"
#import "RCMusicInfoModel.h"
#import "RCMusicCategoryInfoModel.h"
#import "SVProgressHUD.h"
#import "RCMusicChannelResponse.h"
#import "RCMusicSheetResponse.h"
#import "RCMusicResponse.h"
#import "RCMusicDetail.h"
#import "RCMusicEffectInfoModel.h"

@implementation RCMusicEngineDataSourceHifiveImpl
- (void)dealloc {
    
}
+ (instancetype)instance {
    static RCMusicEngineDataSourceHifiveImpl *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RCMusicEngineDataSourceHifiveImpl alloc] init];
    });
    return instance;
}

- (void)initialized {
//    RCMusicEngine.shareInstance().initWithAppId("6f78321c38ee4db3bb4dae7e56d464b1", serverCode: "ca41ad68e8054610a2", clientId: Environment.currentUserId, version: "V4.1.2", success: { _ in
//        log.verbose("register hifive success")
//    }, fail: {error in
//        fatalError("register hifive failed")
//    })
}

- (void)fetchCategories:(void(^)(NSArray<RCMusicCategoryInfo> * _Nullable categories))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        __block NSString *channelId;
        dispatch_group_enter(group);
        [RCMusicDataManager fetchChannelWithCompletion:^(NSArray<RCMusicChannelData *> * _Nullable channels, NSError * _Nonnull error) {
            if (channels != nil) {
                if (channels.count > 0) {
                    channelId = channels.firstObject.groupId;
                } else {
                    [SVProgressHUD showErrorWithStatus:@"无数据"];
                    completion(nil);
                }
            } else {
                if (error) {
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"音乐信息获取失败 code %ld",(long)error.code]];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"音乐信息获取失败"];
                }
                completion(nil);
            }
            dispatch_group_leave(group);
        }];

        dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
            if (channelId != nil) {
                [RCMusicDataManager fetchCategoriesWithChannelId:channelId completion:^(NSArray<RCMusicSheetRecord *> * _Nullable sheets, NSError * _Nonnull error) {
                    if (sheets != nil && sheets.count > 0) {
                        NSMutableArray *result = [@[] mutableCopy];
                        for (RCMusicSheetRecord *record in sheets) {
                            RCMusicCategoryInfoModel *model = [RCMusicCategoryInfoModel new];
                            model.categoryId = record.sheetId.stringValue;
                            model.categoryName = record.sheetName;
                            [result addObject:model];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion([result copy]);
                        });
                    } else {
                        if (error) {
                            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"音乐类别信息获取失败 code %ld",(long)error.code]];
                        } else {
                            [SVProgressHUD showErrorWithStatus:@"音乐类别信息获取失败"];
                        }
                        completion(nil);
                    }
                }];
            }
        });
    });
}

- (void)fetchOnlineMusicsByCategoryId:(NSString *)categoryId completion:(void(^)(NSArray<RCMusicInfo> * _Nullable musics))completion {
    [RCMusicDataManager fetchMusicsWithSheetId:categoryId refresh:NO completion:^(NSArray<RCMusicRecord *> * _Nullable musics, NSError * _Nonnull error) {
        if (musics != nil) {
            NSMutableArray *result = [@[] mutableCopy];
            for (RCMusicRecord *record in musics) {
                RCMusicInfoModel *model = [RCMusicInfoModel new];
                model.coverUrl = record.coverUrl;
                model.musicName = record.musicName;
                model.author = record.authorName;
                model.albumName = record.albumName;
                model.musicId = record.musicId;
                [result addObject:model];
            }
            completion([result copy]);
        } else {
            if (error) {
                [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"音乐列表信息获取失败 code %ld",(long)error.code]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"音乐列表信息获取失败"];
            }
            completion(nil);
        }
    }];
}

- (void)fetchCollectMusics:(void(^)(NSArray<RCMusicInfo> * _Nullable musics))completion {
    NSArray *local = RCMusicDataManager.allMusics;
    completion([RCMusicDataManager.allMusics copy]);
}

- (void)fetchMusicDetailWithInfo:(id<RCMusicInfo> _Nonnull)info completion:(void(^)(id<RCMusicInfo> music))completion; {
    [RCMusicDataManager trafficHQListenWithMusicId:info.musicId audioFormat:nil audioRate:nil success:^(RCMusicDetail * _Nullable response) {
        info.fileUrl = response.fileUrl;
        info.size = [NSByteCountFormatter stringFromByteCount:response.fileSize countStyle:NSByteCountFormatterCountStyleFile];
        completion(info);
    } fail:^(NSError * _Nullable error) {
        [SVProgressHUD showErrorWithStatus:@"获取音乐详细信息失败"];
        completion(nil);
    }];
}

- (void)fetchSearchResultWithKeyWord:(NSString *)keyWord completion:(void(^)(NSArray<RCMusicInfo> *musics))completion {
    [RCMusicDataManager searchMusicWithKeyWord:keyWord completion:^(NSArray<RCMusicRecord *> * _Nullable musics, NSError * _Nonnull error) {
        if (musics != nil) {
            if (musics.count != 0) {
                NSMutableArray *result = [@[] mutableCopy];
                for (RCMusicRecord *record in musics) {
                    RCMusicInfoModel *model = [RCMusicInfoModel new];
                    model.coverUrl = record.coverUrl;
                    model.musicName = record.musicName;
                    model.author = record.authorName;
                    model.albumName = record.albumName;
                    model.musicId = record.musicId;
                    [result addObject:model];
                }
                completion([result copy]);
            } else {
                [SVProgressHUD showSuccessWithStatus:@"无数据"];
            }
            
        } else {
            [SVProgressHUD showErrorWithStatus:@"搜索结果获取失败"];
            completion(nil);
        }
    }];
}

- (BOOL)musicIsExist:(id<RCMusicInfo>)info {
    return [RCMusicDataManager musicIsExist:info.musicId];
}
// sound effect
- (void)fetchSoundEffectsWithCompletion:(void(^)(NSArray<RCMusicEffectInfo> * _Nullable effects))completion {
    
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"RCMusicSource.bundle"];
    
    RCMusicEffectInfoModel *model1 = [RCMusicEffectInfoModel new];
    model1.soundId = 1;
    model1.filePath = [bundlePath stringByAppendingPathComponent:@"intro_effect.mp3"];
    model1.effectName = @"进场";
    
    RCMusicEffectInfoModel *model2 = [RCMusicEffectInfoModel new];
    model2.soundId = 2;
    model2.filePath = [bundlePath stringByAppendingPathComponent:@"cheering_effect.mp3"];
    model2.effectName = @"欢呼";
    
    RCMusicEffectInfoModel *model3 = [RCMusicEffectInfoModel new];
    model3.soundId = 3;
    model3.filePath = [bundlePath stringByAppendingPathComponent:@"clap_effect.mp3"];
    model3.effectName = @"鼓掌";
    
    NSArray<RCMusicEffectInfo> *result = (NSArray<RCMusicEffectInfo> *)@[model1,model2,model3];
    
    completion(result);
}

- (void)addLocalMusic:(UIViewController *)rootViewController {
    [RCMusicDataManager addLocalMusic:rootViewController];
}
@end
