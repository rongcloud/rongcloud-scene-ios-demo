//
//  ChatGPUImageHandle.m
//  SealRTC
//
//  Created by LiuLinhong on 2019/02/21.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "ChatGPUImageHandler.h"
#import "GPUImageOutputCamera.h"

@interface ChatGPUImageHandler ()

@property (nonatomic, strong) GPUImageOutputCamera *outputCamera;
@property (nonatomic, strong) GPUImageView *imageView;
@property (nonatomic, strong) GPUImageFilter *filter;

@end

@implementation ChatGPUImageHandler

- (instancetype)init
{
    if (self = [super init])
    {
        [self initGPUFilter];
    }
    return self;
}

- (void)initGPUFilter
{
    [self.outputCamera addTarget:self.filter];
    [self.filter addTarget:self.imageView];
}

- (nullable CMSampleBufferRef)onGPUFilterSource:(CMSampleBufferRef)sampleBuffer
{
    if (!self.filter || !sampleBuffer)
        return nil;
    
    if (!CMSampleBufferIsValid(sampleBuffer))
        return nil;
    
    [self.filter useNextFrameForImageCapture];
    
    [self.outputCamera processVideoSampleBuffer:sampleBuffer];
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    GPUImageFramebuffer *framebuff = [self.filter framebufferForOutput];
    CVPixelBufferRef pixelBuff = [framebuff pixelBuffer];
    CVPixelBufferLockBaseAddress(pixelBuff, 0);
    
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuff, &videoInfo);
    
    CMSampleTimingInfo timing = {currentTime, currentTime, kCMTimeInvalid};
    if (videoInfo == NULL)
        return nil;
    
    CMSampleBufferRef processedSampleBuffer = NULL;
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuff, YES, NULL, NULL, videoInfo, &timing, &processedSampleBuffer);
    
    CFRelease(videoInfo);
    CVPixelBufferUnlockBaseAddress(pixelBuff, 0);
//    CFAutorelease(processedSampleBuffer);
    return processedSampleBuffer;
}

#pragma mark - Getter

- (GPUImageFilter *)filter
{
    if (!_filter)  {
        _filter = [[GPUImageFilter alloc] init];
    }
    return _filter;
}

- (GPUImageOutputCamera *)outputCamera
{
    if (!_outputCamera) {
        _outputCamera = [[GPUImageOutputCamera alloc] init];
    }
    return _outputCamera;
}

- (GPUImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[GPUImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _imageView;
}

@end
