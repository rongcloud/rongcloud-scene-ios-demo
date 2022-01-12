//
//  RCMusicEngineDelegateMediator.m
//  RCE
//
//  Created by xuefeng on 2021/11/25.
//

#import "RCMusicEngineDelegateHifiveImpl.h"
#import "RCMusicDataManager.h"
#import "RCMusicDownloader.h"

@implementation RCMusicEngineDelegateHifiveImpl
- (void)dealloc {
    
}
+ (instancetype)instance {
    static RCMusicEngineDelegateHifiveImpl *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[RCMusicEngineDelegateHifiveImpl alloc] init];
    });
    return instance;
}

- (void)downloadedMusic:(id <RCMusicInfo>)music completion:(void(^)(BOOL success))completion {
    [RCMusicDownloader downloadWithInfo:music progress:nil downloadFinish:^(NSString * _Nullable filePath, NSURLResponse * _Nullable response) {
        BOOL result = [RCMusicDataManager storageMusic:music srcPath:filePath fileName:music.musicId];
        completion(result);
    } completionHandler:nil];
}

- (void)deleteMusic:(id <RCMusicInfo>)music completion:(void(^)(BOOL success))completion {
    BOOL result = [RCMusicDataManager deleteMusic:music];
    completion(result);
}

- (void)topMusic:(id<RCMusicInfo>)music1 withMusic:(id<RCMusicInfo>)music2 completion:(void(^)(BOOL success))completion {
    BOOL result = [RCMusicDataManager topMusic:music1 withMusic:music2];
    completion(result);
}


@end
