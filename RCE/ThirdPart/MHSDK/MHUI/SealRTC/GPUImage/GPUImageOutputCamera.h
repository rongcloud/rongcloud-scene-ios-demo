#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <GPUImage/GPUImage.h>

//Optionally override the YUV to RGB matrices
void setColorConversion601( GLfloat conversionMatrix[9] );
void setColorConversion601FullRange( GLfloat conversionMatrix[9] );
void setColorConversion709( GLfloat conversionMatrix[9] );


/**
 A GPUImageOutput that provides frames from either camera
*/
@interface GPUImageOutputCamera : GPUImageOutput
{
    NSUInteger numberOfFramesCaptured;
    CGFloat totalFrameTimeDuringCapture;

    GPUImageRotationMode outputRotation, internalRotation;
    dispatch_semaphore_t frameRenderingSemaphore;
        
    BOOL captureAsYUV;
    GLuint luminanceTexture, chrominanceTexture;
}

/// This enables the benchmarking mode, which logs out instantaneous and average frame times to the console
@property(readwrite, nonatomic) BOOL runBenchmark;

- (id)init;
- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// @name Benchmarking

/** When benchmarking is enabled, this will keep a running average of the time from uploading, processing, and final recording or display
 */
- (CGFloat)averageFrameDurationDuringCapture;

- (void)resetBenchmarkAverage;

@end
