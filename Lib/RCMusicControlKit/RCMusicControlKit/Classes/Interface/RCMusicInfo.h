//
//  RCMusicData.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCMusicInfo <NSObject,NSCoding>
@required
//下载地址
@property (nullable, nonatomic, copy) NSString *fileUrl;
//封面图片地址
@property (nullable, nonatomic, copy) NSString *coverUrl;
//音乐名字
@property (nullable, nonatomic, copy) NSString *musicName;
//作者
@property (nullable, nonatomic, copy) NSString *author;
//专辑名称
@property (nullable, nonatomic, copy) NSString *albumName;
//歌曲唯一Id
@property (nullable, nonatomic, copy) NSString *musicId;
//格式化后的字符串  1K 1M 1G ....
@property (nullable, nonatomic, copy) NSString *size;
//计算属性，本地是否已经下载
@property (nullable, nonatomic, strong) NSNumber *isLocal;
//两首音乐是否相同
- (BOOL)isEqualToMusic:(nullable id<RCMusicInfo>)music;
@end

NS_ASSUME_NONNULL_END

