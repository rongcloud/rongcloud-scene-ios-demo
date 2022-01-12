//
//  RCChatroomSceneAudioRecorder.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/1.
//

#import <AVFoundation/AVFoundation.h>

#import "RCChatroomSceneAudioRecorder.h"

static NSString *kRCCSAudioFileNamePre = @"RCChatroomRecord_";

@interface RCChatroomSceneAudioRecorder ()
{
    AVAudioRecorder *_recorder;
}

@property (nonatomic, strong) NSDictionary *recordSettings;

@end

@implementation RCChatroomSceneAudioRecorder

+ (instancetype)defaultRecorder {
    static dispatch_once_t onceToken;
    static RCChatroomSceneAudioRecorder *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RCChatroomSceneAudioRecorder alloc] init];
        instance.recordSettings = @{
            AVFormatIDKey : @(kAudioFormatLinearPCM),
            AVSampleRateKey : @(8000),
            AVNumberOfChannelsKey : @1,
            AVLinearPCMIsNonInterleaved : @NO,
            AVLinearPCMIsFloatKey : @NO,
            AVLinearPCMIsBigEndianKey : @NO
        };
    });
    return instance;
}

+ (instancetype)HQRecorder {
    static dispatch_once_t onceToken;
    static RCChatroomSceneAudioRecorder *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RCChatroomSceneAudioRecorder alloc] init];
        instance.recordSettings = @{
            AVFormatIDKey : @(kAudioFormatMPEG4AAC_HE),
            AVNumberOfChannelsKey : @1,
            AVEncoderBitRateKey : @(32000)
        };
    });
    return instance;
}

- (BOOL)start {
    AVAudioSession *session = AVAudioSession.sharedInstance;
    
    switch (session.recordPermission) {
        case AVAudioSessionRecordPermissionDenied:
            [self permissionNeedOpenSetting];
            return NO;
            
        case AVAudioSessionRecordPermissionUndetermined:
        {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            __block BOOL result = NO;
            [session requestRecordPermission:^(BOOL granted) {
                result = granted;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            if (result == NO) return NO;
        }
            break;
            
        default:
            break;
    }
    
    NSError *error;
    
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (error) {
        NSLog(@"audio session set category fail: %@", error.localizedDescription);
        return NO;
    }
    
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"audio session set active fail: %@", error.localizedDescription);
        return NO;
    }
    
    long time = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *fileName = [NSString stringWithFormat:@"%@%ld.wav", kRCCSAudioFileNamePre, time];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    
    NSDictionary<NSString *, id> *settings = @{
        AVSampleRateKey: @(44100),
        AVFormatIDKey: @(kAudioFormatLinearPCM),
        AVLinearPCMBitDepthKey: @(16),
        AVNumberOfChannelsKey: @(1),
        AVEncoderAudioQualityKey: @(AVAudioQualityHigh),
    };
    
    _recorder = [[AVAudioRecorder alloc] initWithURL:fileURL settings:settings error:&error];
    if (error) {
        NSLog(@"audio session recorder init fail: %@", error.localizedDescription);
        return NO;
    }
    
    _recorder.meteringEnabled = YES;
    [_recorder prepareToRecord];
    return [_recorder record];
}

- (void)stop:(void(^)(NSData *data, NSTimeInterval duration))completion {
    if (_recorder && _recorder.isRecording) {
        NSTimeInterval time = _recorder.currentTime;
        [_recorder stop];
        NSData *data = [NSData dataWithContentsOfURL:_recorder.url];
        completion(data, time);
        [_recorder deleteRecording];
    } else {
        completion(nil, 0);
    }
}

#pragma mark - mic permission -

- (void)permissionNeedOpenSetting {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"请到设置 -> 隐私 -> 麦克风 ，打开访问权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:sureAction];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Clear -

- (void)clear {
    NSArray *contents = [NSFileManager.defaultManager contentsAtPath:NSTemporaryDirectory()];
    for (NSString *fileName in contents) {
        if ([fileName hasPrefix:kRCCSAudioFileNamePre]) {
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            [NSFileManager.defaultManager removeItemAtPath:filePath error:nil];
        }
    }
}

@end
