//
//  RCChatroomSceneToolBar.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/29.
//

#import <Masonry/Masonry.h>

#import "UIImage+Bundle.h"
#import "RCChatroomSceneToolBar.h"
#import "RCChatroomAudioRecordView.h"
#import "RCChatroomSceneInputViewController.h"
#import "RCChatroomSceneToolBarConfig.h"
#import "RCChatroomSceneInputBarConfig.h"
 
@interface RCChatroomSceneToolBar () <RCChatroomSceneInputViewControllerDelegate, RCChatroomAudioRecordViewDelegate>

@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIStackView *commonStackView;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) RCChatroomAudioRecordView *recordView;
@property (nonatomic, strong) RCChatroomSceneToolBarConfig *config;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation RCChatroomSceneToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _config = [RCChatroomSceneToolBarConfig default];

        [self addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets(_config.contentInsets);
        }];
        
        [self.containerView addSubview:self.chatButton];
        [self.chatButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.containerView).with.offset(12);
            make.centerY.equalTo(self.containerView);
            make.size.mas_equalTo(_config.chatButtonSize);
        }];
        
        [self.containerView addSubview:self.commonStackView];
        [self.commonStackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.width.mas_greaterThanOrEqualTo(12);
            make.height.lessThanOrEqualTo(self.containerView);
            make.left.equalTo(self.chatButton.mas_right).offset(12);
        }];
        
        [self.containerView addSubview:self.stackView];
        [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.containerView);
            make.right.equalTo(self.containerView).offset(-12);
            make.width.mas_greaterThanOrEqualTo(12);
            make.height.lessThanOrEqualTo(self.containerView);
            make.left.greaterThanOrEqualTo(self.commonStackView.mas_right).offset(12);
        }];
        
        [self setupUI];
    }
    return self;
}

- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
    }
    return _containerView;
}
- (UIButton *)chatButton {
    if (_chatButton == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = _config.chatButtonBackgroundColor;
        [button setTitleColor:_config.chatButtonTextColor forState:UIControlStateNormal];
        [button setTitle:_config.chatButtonTitle forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:_config.chatButtonTextSize]];
        button.contentEdgeInsets = _config.chatButtonInsets;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        button.layer.cornerRadius = _config.chatButtonBackgroundCorner;
        button.layer.masksToBounds = YES;
        [button addTarget:self
                   action:@selector(buttonDidClick:)
         forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [UIImage bundleImageNamed:@"toolbar_chat_input"];
        [button setImage:image forState:UIControlStateNormal];
        _chatButton = button;
    }
    return _chatButton;
}

- (void)buttonDidClick:(UIButton *)button {
    RCChatroomSceneInputViewController *controller = [[RCChatroomSceneInputViewController alloc] initWithConfig:[RCChatroomSceneInputBarConfig default] inputDelegate:self];
    [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
}

- (RCChatroomAudioRecordView *)recordView {
    if (_recordView == nil) {
        _recordView = [[RCChatroomAudioRecordView alloc] init];
    }
    return _recordView;
}

- (UIStackView *)commonStackView {
    if (_commonStackView == nil) {
        _commonStackView = [[UIStackView alloc] init];
        _commonStackView.distribution = UIStackViewDistributionEqualSpacing;
        _commonStackView.alignment = UIStackViewAlignmentLeading;
        _commonStackView.spacing = 12;
    }
    return _commonStackView;
}

- (UIStackView *)stackView {
    if (_stackView == nil) {
        _stackView = [[UIStackView alloc] init];
        _stackView.distribution = UIStackViewDistributionEqualSpacing;
        _stackView.alignment = UIStackViewAlignmentTrailing;
        _stackView.spacing = 12;
    }
    return _stackView;
}

- (void)setConfig:(RCChatroomSceneToolBarConfig *)config {
    if (config == nil) return;
    [_config merge:config];
    [self setupUI];
}

- (void)setupUI {
    self.backgroundColor = self.config.backgroundColor;

    CGSize size = self.config.chatButtonSize;
    [self.chatButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width);
        make.height.mas_equalTo(size.height);
    }];
    
    [self.chatButton setTitle:self.config.chatButtonTitle
                     forState:UIControlStateNormal];
    
    if (self.config.recordButtonEnable) {
        self.recordView.config = self.config;
        [self.containerView addSubview:self.recordView];
        self.recordView.delegate = self;
        [self.chatButton setImage:nil forState:UIControlStateNormal];
        switch (self.config.recordButtonPosition) {
            case RCChatroomSceneRecordButtonPositionLeft:
            {
                self.chatButton.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 0);
                [self.recordView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.left.centerY.equalTo(self.chatButton);
                    make.width.height.mas_equalTo(44);
                }];
            }
                break;
                
            case RCChatroomSceneRecordButtonPositionRight:
            {
                self.chatButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 24);
                [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.centerY.equalTo(self.chatButton);
                    make.width.height.mas_equalTo(44);
                }];
            }
                break;
        }
    } else {
        [self.recordView removeFromSuperview];
        self.chatButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
        self.chatButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4);
        UIImage *image = [UIImage bundleImageNamed:@"toolbar_chat_input"];
        [self.chatButton setImage:image forState:UIControlStateNormal];
    }
    
    for (UIView *view in self.commonStackView.arrangedSubviews) {
        [self.commonStackView removeArrangedSubview:view];
    }
    for (UIView *view in self.config.commonActions) {
        [self.commonStackView addArrangedSubview:view];
    }
    
    for (UIView *view in self.stackView.arrangedSubviews) {
        [self.stackView removeArrangedSubview:view];
    }
    for (UIView *view in self.config.actions) {
        [self.stackView addArrangedSubview:view];
    }
}

#pragma mark - RCChatroomSceneInputViewControllerDelegate -

- (void)inputViewDidClickSendButtonWith:(NSString *)content {
    if ([self.delegate respondsToSelector:@selector(textInputViewSendText:)]) {
        [self.delegate textInputViewSendText:content];
    }
}

#pragma mark - RCChatroomAudioRecordViewDelegate -
- (BOOL)audioRecordShouldBegin {
    if ([self.delegate respondsToSelector:@selector(audioRecordShouldBegin)]) {
        return [self.delegate audioRecordShouldBegin];
    } else {
        return YES;
    }
}
- (void)audioRecordDidBegin {
    if ([self.delegate respondsToSelector:@selector(audioRecordDidBegin)]) {
        [self.delegate audioRecordDidBegin];
    }
}

- (void)audioRecordDidCancel {
    if ([self.delegate respondsToSelector:@selector(audioRecordDidCancel)]) {
        [self.delegate audioRecordDidCancel];
    }
}

- (void)audioRecordDidEnd:(NSData *)data time:(NSTimeInterval)time {
    long currentTime = [[NSDate date] timeIntervalSince1970] * 1000;
    NSString *fileName = [NSString stringWithFormat:@"%ld.wav", currentTime];
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:fileName];
    [data writeToFile:filePath atomically:YES];
    if ([self.delegate respondsToSelector:@selector(audioRecordDidEnd:time:)]) {
        [self.delegate audioRecordDidEnd:data time:time];
    }
}

@end
