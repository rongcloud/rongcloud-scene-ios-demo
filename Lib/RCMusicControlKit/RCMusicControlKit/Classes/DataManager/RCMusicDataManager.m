//
//  RCMusicDataManager.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import "RCMusicDataManager.h"
#import "NSString+RCMMD5.h"
#import "RCMusicDataPath.h"
#import "RCMusicWebService.h"
#import "RCMusicChannelResponse.h"
#import "RCMusicSheetResponse.h"
#import "RCMusicResponse.h"
#import "RCMusicDetail.h"
#import "NSObject+YYModel.h"
#import <CoreServices/UTType.h>
#import <AVFoundation/AVFoundation.h>
#import "RCMusicInfoModel.h"
#import "NSString+RCMMD5.h"
#import "RCMusicDownloader.h"

NSString *const RCMusicLocalDataChangedNotification = @"constRCMusicLocalDataChangedNotification";

@interface RCMusicDataManager ()<UIDocumentPickerDelegate>
@property (atomic, strong) NSMutableArray<RCMusicInfo> *allMusics;
@property (nonatomic, strong) NSMutableSet *existSet;
@end

@implementation RCMusicDataManager

#pragma mark - LOCAL DATA

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static  RCMusicDataManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RCMusicDataManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self loadLocalData];
    }
    return self;
}

- (void)loadLocalData {
    NSString *path = [RCMusicDataPath musicsLocalDataPathWithMusicsDir:[RCMusicDataPath musicsDir:[RCMusicDataPath document]]];
    self.existSet = [NSMutableSet set];
    NSError *error;
    NSMutableArray *data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (data != nil) {
        self.allMusics = (NSMutableArray<RCMusicInfo> *)data;
        if (self.allMusics && self.allMusics.count > 0) {
            for (id<RCMusicInfo> obj in self.allMusics) {
                [self.existSet addObject:obj.musicId];
            }
        }
    } else {
        self.allMusics = (NSMutableArray<RCMusicInfo> *)[@[] mutableCopy];
    }
}

+ (NSArray<RCMusicInfo> *)allMusics {
    return [[RCMusicDataManager shareInstance].allMusics copy];
}

+ (BOOL)storageMusic:(id<RCMusicInfo>)music srcPath:(NSString *)srcPath fileName:(NSString *)fileName {
    BOOL result = NO;
    @synchronized ([RCMusicDataManager shareInstance].allMusics) {
        
        NSString *dstPath = [NSString stringWithFormat:@"%@/%@",[RCMusicDataPath musicsDir:[RCMusicDataPath document]],fileName];
        
        if (![self moveFile:srcPath to:dstPath]) {
            NSLog(@"move file failure");
            return NO;
        }
        
        NSMutableArray *marr = [NSMutableArray arrayWithArray:[self allMusics]];
        
        __block BOOL isExist = NO;
        
        [marr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToMusic:music]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        
        if (!isExist) {
            result = YES;
            [marr addObject:music];
        }
        NSString *musicId = music.musicId;
        [RCMusicDataManager shareInstance].allMusics = [(NSMutableArray<RCMusicInfo> *)marr mutableCopy];
        [[RCMusicDataManager shareInstance].existSet addObject:musicId];
        [self archive];
    }
        
    return result;
}

+ (BOOL)deleteMusic:(id<RCMusicInfo>)music {
    BOOL result = NO;
    NSString *filePath = [RCMusicDataPath musicsDir:[RCMusicDataPath document]];
    filePath = [NSString stringWithFormat:@"%@/%@",filePath,music.musicId];
    @synchronized ([RCMusicDataManager shareInstance].allMusics) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            //文件不存在
            return result;
        }
        NSError *error;
        if ([[NSFileManager defaultManager] isDeletableFileAtPath:filePath]) {
            for (id<RCMusicInfo> info in [RCMusicDataManager shareInstance].allMusics) {
                if ([info isEqualToMusic:music]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                    [[RCMusicDataManager shareInstance].allMusics removeObject:info];
                    [[RCMusicDataManager shareInstance].existSet removeObject:music.musicId];
                    [self archive];
                    break;
                }
            }
        } else {
            NSLog(@"removing file is not allowed to be remove");
        }
    }
    return result;
}

+ (BOOL)topMusic:(nullable id<RCMusicInfo>)music1 withMusic:(id<RCMusicInfo>)music2 {
    BOOL result = NO;
    
    if ([RCMusicDataManager shareInstance].allMusics == nil || [RCMusicDataManager shareInstance].allMusics.count <= 1)
        return result;
    
    @synchronized ([RCMusicDataManager shareInstance].allMusics) {
        NSInteger idx1 = -1;
        NSInteger idx2 = -1;
        
        NSMutableArray *musics = [[RCMusicDataManager shareInstance].allMusics mutableCopy];
        
        for (int i = 0; i < musics.count; i++) {
            id <RCMusicInfo> obj = musics[i];
            if ([obj isEqualToMusic:music2]) {
                idx2 = i;
            }
        }
        
        if (idx2 == -1) return result;
        
        [musics removeObjectAtIndex:idx2];
        
        if (music1 == nil) {
            [musics insertObject:music2 atIndex:0];
        } else {
            for (int i = 0; i < musics.count; i++) {
                id <RCMusicInfo> obj = musics[i];
                if ([obj isEqualToMusic:music1]) {
                    idx1 = i;
                }
            }
            
            if (idx1 == -1) return result;
            
            if (musics.count == 1) {
                [musics addObject:music2];
            } else {
                [musics insertObject:music2 atIndex:idx1 + 1];
            }
        }
        
        [RCMusicDataManager shareInstance].allMusics = (NSMutableArray<RCMusicInfo> *)musics;
        [self archive];
        result = YES;
    }
    
    return result;
}

+ (BOOL)archive {
    NSString *path = [RCMusicDataPath musicsLocalDataPathWithMusicsDir:[RCMusicDataPath musicsDir:[RCMusicDataPath document]]];
    BOOL result = [NSKeyedArchiver archiveRootObject:[[RCMusicDataManager shareInstance].allMusics mutableCopy] toFile:path];
    if (result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:RCMusicLocalDataChangedNotification object:nil];
        });
    } else {
        NSLog(@"music data archive fail");
    }
    return result;
}


+ (BOOL)moveFile:(NSString *)srcPath to:(NSString *)dstPath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath]) {
        //已经存在文件
        return YES;
    }
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] moveItemAtURL:[NSURL fileURLWithPath:srcPath] toURL:[NSURL fileURLWithPath:dstPath] error:&error];
    if (error != nil) {
        NSLog(@"move failure %@",error);
    }
    return success;
}

+ (BOOL)removeFile:(NSString *)path {
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        BOOL result = [[NSFileManager defaultManager] removeItemAtURL:[NSURL fileURLWithPath:path] error:&error];
        if (error) {
            NSLog(@"remove exist file failed code: %ld",(long)error.code);
        }
        return result;
    }
    return  NO;
}

#pragma mark - TOOL

+ (BOOL)musicIsExist:(NSString *)musicId {
    return [[RCMusicDataManager shareInstance].existSet containsObject:musicId];
}

#pragma mark - REMOTE DATA

static NSArray<RCMusicChannelData *> *k_channels;
static NSArray<RCMusicSheetRecord *> *k_sheets;
static NSMutableDictionary<NSString *, NSArray<RCMusicRecord *> *> *k_musics;

+ (void)fetchChannelWithCompletion:(void (^)(NSArray<RCMusicChannelData *> * _Nullable channels, NSError *error))completion; {
    if (k_channels != nil) {
        completion(k_channels,nil);
    } else {
        [RCMusicWebService channelWithSuccess:^(NSArray<RCMusicChannelData *> * _Nullable response) {
            k_channels = response;
            completion(k_channels,nil);
        } fail:^(NSError * _Nonnull error) {
            completion(nil,error);
        }];
    }
}

+ (void)fetchCategoriesWithChannelId:(NSString *)channelId completion:(void (^)(NSArray<RCMusicSheetRecord *> * _Nullable sheets, NSError *error))completion {
    if (k_sheets != nil) {
        completion(k_sheets,nil);
    } else {
        [RCMusicWebService channelSheetWithGroupId:channelId language:@"0" recoNum:nil page:@"1" pageSize:@"100" success:^(RCMusicSheetData * _Nullable response) {
            if (response != nil && response.record != nil) {
                k_sheets = response.record;
                completion(k_sheets,nil);
            } else {
                completion(nil,[[NSError alloc] initWithDomain:@"json error" code:-500 userInfo:@{@"msg":@"返回数据为nil"}]);
            }
        } fail:^(NSError * _Nonnull error) {
            completion(nil,error);
        }];
    }
}

+ (void)fetchMusicsWithSheetId:(NSString *)sheetId refresh:(BOOL)refresh completion:(void (^)(NSArray<RCMusicRecord *> * _Nullable musics, NSError *error))completion {
    
    if (k_musics == nil) {
        k_musics = [@{} mutableCopy];
    }
    
    if (k_musics[sheetId]) {
        completion(k_musics[sheetId],nil);
    }
    
    [RCMusicWebService sheetMusicWithSheetId:sheetId language:@"0" page:@"1" pageSize:@"100" success:^(RCMusicData * _Nullable response) {
        if (response != nil && response.record != nil) {
            k_musics[sheetId] = response.record;
            completion(response.record,nil);
        } else {
            completion(nil,[[NSError alloc] initWithDomain:@"json error" code:-500 userInfo:@{@"msg":@"返回数据为nil"}]);
        }
    } fail:^(NSError * _Nonnull error) {
        completion(nil,error);
    }];
}

+ (void)trafficHQListenWithMusicId:(nonnull NSString *)musicId
                      audioFormat:(nullable NSString *)audioFormat
                        audioRate:(nullable NSString *)audioRate
                          success:(void (^)(RCMusicDetail  * _Nullable response))success
                              fail:(void (^)(NSError * _Nullable error))failure {
    [RCMusicWebService trafficHQListenWithMusicId:musicId audioFormat:audioFormat audioRate:audioRate success:success fail:failure];
}

+ (void)searchMusicWithKeyWord:(nonnull NSString *)keyword completion:(void (^)(NSArray<RCMusicRecord *> * _Nullable musics, NSError *error))completion; {
    [RCMusicWebService searchMusicWithTagIds:nil priceFromCent:nil priceToCent:nil bpmFrom:nil bpmTo:nil durationFrom:nil durationTo:nil keyword:keyword language:@"0" searchFiled:nil searchSmart:nil page:@"1" pageSize:@"100" success:^(id  _Nullable response) {
        if (response != nil && response[@"record"] != nil) {
            NSMutableArray *marr = [@[] mutableCopy];
            for (NSDictionary *recDict in (NSArray *)response[@"record"]) {
                RCMusicRecord *record = [RCMusicRecord yy_modelWithDictionary:recDict];
                [marr addObject:record];
            }
            completion([marr copy],nil);
        } else {
            completion(nil,[[NSError alloc] initWithDomain:@"json error" code:-500 userInfo:@{@"msg":@"返回数据为nil"}]);
        }
    } fail:^(NSError * _Nullable error) {
        completion(nil,error);
    }];
}


+ (NSURLSessionDownloadTask *)downloadWithMusic:(id<RCMusicInfo> _Nonnull)music
                                       progress:(void (^)(NSProgress * _Nullable downloadProgress)) downloadProgressBlock
                                 downloadFinish:(void(^)(id <RCMusicInfo> _Nullable music))downloadFinish
                              completionHandler:(void (^)(NSURLResponse * _Nullable response, NSString * _Nullable filePath, NSError * _Nullable error))completionHandler; {
    return [RCMusicDownloader downloadWithInfo:music progress:downloadProgressBlock downloadFinish:^(NSString * _Nullable filePath, NSURLResponse * _Nullable response) {
        BOOL result = [self storageMusic:music srcPath:filePath fileName:music.musicId];
        if (result && downloadFinish) {
            downloadFinish(music);
        }
    } completionHandler:^(NSURLResponse * _Nullable response, NSString * _Nullable filePath, NSError * _Nullable error) {}];
}

+ (void)addLocalMusic:(UIViewController *)rootViewController {
    UIDocumentPickerViewController *picker;
    NSArray *types = @[
        @"public.audio",
        @"public.mp3",
        @"public.mpeg-4-audio",
        @"com.apple.protected-​mpeg-4-audio ",
        @"public.ulaw-audio",
        @"public.aifc-audio",
        @"public.aiff-audio",
        @"com.apple.coreaudio-​format"
    ];
    picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeOpen];
    picker.delegate = [RCMusicDataManager shareInstance];
    [rootViewController presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls {
    
    if (urls == nil || urls.count < 0) {
        NSLog(@"add local music failed, urls is empty");
        return;
    }
    
    NSURL *fileUrl = urls.firstObject;
    
    if (![fileUrl startAccessingSecurityScopedResource]) {
        NSLog(@"add local music accessing security");
        return;
    }
    
    NSString *musicDir = [RCMusicDataPath musicsDir:[RCMusicDataPath document]];
    
    NSString *localFileName = fileUrl.lastPathComponent;
    
    NSString *localFilePath = [NSString stringWithFormat:@"%@/%@",musicDir,localFileName];
    
    NSString *localFileAuthor;
    
    NSError *error;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localFilePath]) {
        [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&error];
        if (error) {
            NSLog(@"add local music remove exist file failed code: %ld",(long)error.code);
        }
    }
    
    [[NSFileManager defaultManager] copyItemAtURL:fileUrl toURL:[NSURL fileURLWithPath:localFilePath] error:&error];
    if (error) {
        NSLog(@"add local music copy item failed code: %ld",(long)error.code);
        return;
    }
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:fileUrl];
    
    for (AVMetadataItem *item in asset.metadata) {
        if (item.commonKey == AVMetadataCommonKeyTitle && item.commonKey != nil) {
            localFileName = (NSString *)item.value;
        }
        if (item.commonKey == AVMetadataCommonKeyArtist && item.commonKey != nil) {
            localFileAuthor = (NSString *)item.value;
        }
    }
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:localFilePath error:&error];
    
    NSNumber *size = attributes[NSFileSize];
    
    RCMusicInfoModel *music = [RCMusicInfoModel new];
    
    music.musicName = localFileName;
    music.author = localFileAuthor;
    music.size = [[size stringValue] sizeFormatString];
    music.musicId = [[NSString stringWithFormat:@"%@%@",music.musicName,music.size] rcm_md5];
    
    NSMutableArray *marr = [[RCMusicDataManager shareInstance].allMusics mutableCopy];
    [marr insertObject:music atIndex:0];
    
    [RCMusicDataManager shareInstance].allMusics = [(NSMutableArray<RCMusicInfo> *)marr mutableCopy];
    [[RCMusicDataManager shareInstance].existSet addObject:music.musicId];
    [RCMusicDataManager archive];
    
    [fileUrl stopAccessingSecurityScopedResource];
}
@end
