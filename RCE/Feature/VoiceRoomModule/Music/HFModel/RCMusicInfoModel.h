//
//  RCMusicInfoModel.h
//  RCE
//
//  Created by xuefeng on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import "RCMusicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicInfoModel : NSObject<RCMusicInfo>
@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *musicName;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *albumName;
@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *size;//格式化后的字符串
@property (nonatomic, strong) NSNumber *isLocal;
@end

NS_ASSUME_NONNULL_END
