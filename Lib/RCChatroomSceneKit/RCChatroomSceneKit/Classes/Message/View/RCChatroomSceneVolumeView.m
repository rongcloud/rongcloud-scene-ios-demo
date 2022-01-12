//
//  RCChatroomSceneVolumeView.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/1.
//

#import <Masonry/Masonry.h>

#import "UIImage+Bundle.h"
#import "RCChatroomSceneVolumeView.h"

@interface RCChatroomSceneVolumeView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *volumeView;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation RCChatroomSceneVolumeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self addSubview:self.titleLabel];
        [self addSubview:self.imageView];
        [self addSubview:self.volumeView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self.mas_bottom).offset(-23.5);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(40);
            make.top.equalTo(self).offset(32);
            make.width.mas_equalTo(40);
            make.height.mas_equalTo(70);
        }];
        
        [self.volumeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).offset(11);
            make.bottom.equalTo(self.imageView).offset(-4);
            make.width.mas_equalTo(28);
            make.height.mas_equalTo(49);
        }];
        
        self.layer.cornerRadius = 6;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (CALayer *layer in self.volumeView.layer.sublayers) {
        NSInteger index = layer.name.integerValue;
        layer.frame = CGRectMake(0, 9 * (5 - index), 10 + index * 4, 4);
    }
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = @"手指上滑，取消发送";
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImage *image = [UIImage bundleImageNamed:@"audio_recording_cub"];
        _imageView = [[UIImageView alloc] initWithImage:image];
    }
    return _imageView;
}

- (UIView *)volumeView {
    if (_volumeView == nil) {
        _volumeView = [[UIView alloc] init];
        for (NSInteger i = 0; i < 6; i ++) {
            CALayer *layer = [CALayer layer];
            layer.backgroundColor = UIColor.whiteColor.CGColor;
            layer.cornerRadius = 2;
            layer.name = [NSString stringWithFormat:@"%ld", (long)i];
            layer.hidden = YES;
            [_volumeView.layer addSublayer:layer];
        }
    }
    return _volumeView;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        __weak typeof(self) weakSelf = self;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.4 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [weakSelf update:arc4random() % 6];
        }];
    }
    return _timer;
}

- (void)update:(NSInteger)audioLevel {
    if (audioLevel < 1 || audioLevel > 6) return;
    for (CALayer *layer in self.volumeView.layer.sublayers) {
        NSInteger index = layer.name.integerValue;
        layer.hidden = index >= audioLevel;
    }
}

- (void)startAnimation {
    self.timer.fireDate = NSDate.distantPast;
    [NSRunLoop.mainRunLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopAnimation {
    self.timer.fireDate = NSDate.distantFuture;
}

@end
