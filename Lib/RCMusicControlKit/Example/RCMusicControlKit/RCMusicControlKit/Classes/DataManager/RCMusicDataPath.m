//
//  RCMusicDataPath.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/15.
//

#import "RCMusicDataPath.h"

@implementation RCMusicDataPath
+ (NSString *)document {
    static NSString *doc;
    if (doc) {
        return doc;
    }
    doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return doc;
}

+ (NSString *)musicsDir:(NSString *)basePath {
    if (basePath == nil) {
        NSLog(@"basePath is nil");
        return nil;
    }
    
    static NSString *musicsDir;
    if (musicsDir) {
        return musicsDir;
    }
    NSString *tmp = [basePath stringByAppendingPathComponent:@"rcm_musics"];
    BOOL isDir;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:tmp isDirectory:&isDir];
    if (!(isDir && isExist)) {
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:tmp withIntermediateDirectories:YES attributes:nil error:nil];
        if (success) {
            musicsDir = tmp;
        } else {
            NSLog(@"musics dir create fail");
        }
    } else {
        musicsDir = tmp;
    }
    return musicsDir;
}

+ (NSString *)fileNameWithFileUrl:(NSString *)fileUrl sourceType:(NSString *)sourceType {
    
    if (fileUrl.length == 0 || sourceType.length == 0) {
        return nil;
    }
        
    while (sourceType.length > 1 && [sourceType hasPrefix:@"."]) {
        sourceType = [sourceType substringFromIndex:1];
    }
    
    NSString *dstPath = [NSString stringWithFormat:@"%@.%@",[fileUrl rcm_md5],sourceType];
    return dstPath;
}

+ (NSString *)musicsLocalDataPathWithMusicsDir:(NSString *)musicsDir {
    if (musicsDir == nil || musicsDir.length == 0) {
        NSLog(@"musicsDir must be nonnull");
        return nil;
    }
    return [musicsDir stringByAppendingPathComponent:@"musics.data"];
}
@end
