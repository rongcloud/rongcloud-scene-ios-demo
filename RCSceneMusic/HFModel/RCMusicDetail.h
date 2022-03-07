//
//  RCMusicDetail.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicDetail : NSObject
@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, copy) NSString *waveUrl;
@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *dynamicLyricUrl;
@property (nonatomic, copy) NSString *staticLyricUrl;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, assign) NSInteger expires;
@end

NS_ASSUME_NONNULL_END
