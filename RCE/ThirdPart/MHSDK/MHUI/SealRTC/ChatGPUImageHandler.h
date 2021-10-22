//
//  ChatGPUImageHandle.h
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatGPUImageHandler : NSObject

- (nullable CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
