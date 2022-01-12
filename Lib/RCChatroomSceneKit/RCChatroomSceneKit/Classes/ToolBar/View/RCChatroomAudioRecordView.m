//
//  RCChatroomAudioRecordView.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/1.
//

#import <Masonry/Masonry.h>

#import "UIImage+Bundle.h"
#import "RCChatroomAudioRecordView.h"
#import "RCChatroomSceneAudioRecorder.h"
#import "RCChatroomSceneToolBarConfig.h"
#import "RCChatroomSceneRecorderViewController.h"

@interface RCChatroomAudioRecordView () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, strong) RCChatroomSceneRecorderViewController *recorderController;

@property (nonatomic, strong) UIImage *recordNormalImage;
@property (nonatomic, strong) UIImage *recordHighlightImage;

@end

@implementation RCChatroomAudioRecordView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.layer addSublayer:self.gradientLayer];
        self.layer.masksToBounds = YES;
        
        self.imageView.image = self.recordNormalImage;
        [self addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.mas_equalTo(17);
            make.height.mas_equalTo(21);
        }];
        
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
        gesture.delegate = self;
        gesture.numberOfTouchesRequired = 1;
        gesture.minimumPressDuration = 0.2;
        [self addGestureRecognizer:gesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.width * 0.5;
    self.gradientLayer.frame = self.bounds;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (CAGradientLayer *)gradientLayer {
    if (_gradientLayer == nil) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(1, 1);
        _gradientLayer.colors = @[
            (__bridge id)[UIColor colorWithRed:233 / 255.0 green:43 / 255.0 blue:153 / 255.0 alpha:1.0].CGColor,
            (__bridge id)[UIColor colorWithRed:168 / 255.0 green:53 / 255.0 blue:239 / 255.0 alpha:1.0].CGColor,
        ];
        _gradientLayer.hidden = YES;
    }
    return _gradientLayer;
}

- (UIImage *)recordNormalImage {
    if (_recordNormalImage == nil) {
        _recordNormalImage = [UIImage bundleImageNamed:@"toolbar_record_normal"];
    }
    return _recordNormalImage;
}

- (UIImage *)recordHighlightImage {
    if (nil == _recordNormalImage) {
        _recordNormalImage = [UIImage bundleImageNamed:@"toolbar_record_highlight"];
    }
    return _recordNormalImage;
}

- (RCChatroomSceneRecorderViewController *)recorderController {
    if (_recorderController == nil) {
        _recorderController = [[RCChatroomSceneRecorderViewController alloc] init];
        _recorderController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _recorderController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return _recorderController;
}

- (RCChatroomSceneAudioRecorder *)recorder {
    if (self.config) {
        switch (self.config.recordQuality) {
            case RCChatroomSceneRecordQualityLow:
                return [RCChatroomSceneAudioRecorder defaultRecorder];
            case RCChatroomSceneRecordQualityHigh:
                return [RCChatroomSceneAudioRecorder HQRecorder];
        }
    }
    return [RCChatroomSceneAudioRecorder defaultRecorder];
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.delegate respondsToSelector:@selector(audioRecordShouldBegin)]) {
        return [self.delegate audioRecordShouldBegin];
    }
    return YES;
}
- (void)longPressGestureHandler:(UILongPressGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.state = RCChatroomAudioRecordStateBegin;
            [self performSelector:@selector(audioRecordReachMaxSeconds:)
                       withObject:gesture
                       afterDelay:60];
            break;
        case UIGestureRecognizerStateChanged:
            if (CGRectContainsPoint(self.bounds, point)) {
                self.state = RCChatroomAudioRecordStateRecording;
            } else {
                self.state = RCChatroomAudioRecordStateOutArea;
            }
            break;
        case UIGestureRecognizerStateCancelled:
            self.state = RCChatroomAudioRecordStateEnd;
            break;
        case UIGestureRecognizerStateEnded:
            switch (self.state) {
                case RCChatroomAudioRecordStateBegin:
                case RCChatroomAudioRecordStateRecording:
                    self.state = RCChatroomAudioRecordStateEnd;
                    break;
                case RCChatroomAudioRecordStateOutArea:
                    self.state = RCChatroomAudioRecordStateCancel;
                    break;
                default:
                    break;
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            break;
        default:
            break;
    }
}

- (void)audioRecordReachMaxSeconds:(UILongPressGestureRecognizer *)gesture {
    gesture.enabled = NO;
    gesture.enabled = YES;
}

#pragma mark - touches -

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if (self.beginTime + 0.2 > timeInterval) {
        self.state = RCChatroomAudioRecordStateLack;
    }
}

#pragma mark - state -

- (void)setState:(RCChatroomAudioRecordState)state {
    _state = state;
    switch (state) {
        case RCChatroomAudioRecordStateBegin:
            [self.recorder start];
            if ([self.delegate respondsToSelector:@selector(audioRecordDidBegin)]) {
                [self.delegate audioRecordDidBegin];
            }
            break;
            
        case RCChatroomAudioRecordStateCancel:
        {
            [self.recorder stop:^(NSData * _Nonnull data, NSTimeInterval duration) {
                if ([self.delegate respondsToSelector:@selector(audioRecordDidCancel)]) {
                    [self.delegate audioRecordDidCancel];
                }
            }];
        }
            break;
            
        case RCChatroomAudioRecordStateEnd:
        {
            [self.recorder stop:^(NSData * _Nonnull data, NSTimeInterval duration) {
                if ([self.delegate respondsToSelector:@selector(audioRecordDidEnd:time:)]) {
                    [self.delegate audioRecordDidEnd:data time:duration];
                }
            }];
        }
            break;
            
        default:
            break;
    }
    self.gradientLayer.hidden = [self isRecording];
    if ([self isRecording]) {
        self.gradientLayer.hidden = NO;
        self.imageView.image = self.recordHighlightImage;
    } else {
        self.gradientLayer.hidden = YES;
        self.imageView.image = self.recordNormalImage;
    }
    [self recordStateChanged:state];
}

- (void)recordStateChanged:(RCChatroomAudioRecordState)state {
    [self.recorderController setState:state];
    UIViewController *controller = UIApplication.sharedApplication.keyWindow.rootViewController;
    switch (state) {
        case RCChatroomAudioRecordStateBegin:
        case RCChatroomAudioRecordStateLack:
            if (self.recorderController.presentingViewController == nil && self.recorderController.beingPresented == NO) {
                [controller presentViewController:self.recorderController animated:YES completion:nil];
            }
            break;
        case RCChatroomAudioRecordStateCancel:
        case RCChatroomAudioRecordStateEnd:
            [self.recorderController dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}

- (BOOL)isRecording {
    switch (self.state) {
        case RCChatroomAudioRecordStateBegin:
        case RCChatroomAudioRecordStateRecording:
        case RCChatroomAudioRecordStateOutArea:
            return YES;;
        default:
            return NO;
    }
}

@end
