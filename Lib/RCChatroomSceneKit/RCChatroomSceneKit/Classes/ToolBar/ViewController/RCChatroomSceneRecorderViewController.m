//
//  RCChatroomSceneRecorderViewController.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/1.
//

#import <Masonry/Masonry.h>

#import "UIImage+Bundle.h"
#import "RCChatroomSceneVolumeView.h"
#import "RCChatroomSceneRecorderViewController.h"

@interface RCChatroomSceneRecorderViewController ()

@property (nonatomic, assign) RCChatroomAudioRecordState state;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) RCChatroomSceneVolumeView *volumeView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation RCChatroomSceneRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.clearColor;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (RCChatroomSceneVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView = [[RCChatroomSceneVolumeView alloc] init];
    }
    return _volumeView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImage *image = [UIImage bundleImageNamed:@"audio_recording_outside"];
        _imageView = [[UIImageView alloc] initWithImage:image];
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (void)setState:(RCChatroomAudioRecordState)state {
    if (_state == state) return;
    _state = state;
    switch (state) {
        case RCChatroomAudioRecordStateBegin:
        case RCChatroomAudioRecordStateRecording:
            [self onRecording];
            break;
            
        case RCChatroomAudioRecordStateLack:
            [self onTimeLack];
            break;
            
        case RCChatroomAudioRecordStateOutArea:
            [self onOutside];
            break;
            
        default:
            break;
    }
}

- (void)onRecording {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(160);
    }];
    
    [self.contentView addSubview:self.volumeView];
    [self.volumeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.volumeView startAnimation];
}

- (void)onTimeLack {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    [self.view addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.mas_equalTo(200);
        make.height.mas_equalTo(70);
    }];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
    self.titleLabel.text = @"长按说话";
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.6), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
        self.state = RCChatroomAudioRecordStateIdle;
    });
}

- (void)onOutside {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    self.contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.contentView];
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(160);
    }];
    
    [self.contentView addSubview:self.imageView];
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)onEnd {
    [self.contentView removeFromSuperview];
    [self.volumeView stopAnimation];
}

@end
