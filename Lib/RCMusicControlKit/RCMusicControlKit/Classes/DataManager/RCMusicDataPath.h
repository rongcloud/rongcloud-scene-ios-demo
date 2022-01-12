//
//  RCMusicDataPath.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/12.
//

#import <Foundation/Foundation.h>
#import "NSString+RCMMD5.h"

@interface RCMusicDataPath : NSObject
//document 沙盒路径
+ (nonnull NSString *)document;

//音乐数据存放的目录
+ (nullable NSString *)musicsDir:(nonnull NSString *)basePath;

//归档数据存储地址
+ (nullable NSString *)musicsLocalDataPathWithMusicsDir:(nonnull NSString *)musicsDir;
@end
