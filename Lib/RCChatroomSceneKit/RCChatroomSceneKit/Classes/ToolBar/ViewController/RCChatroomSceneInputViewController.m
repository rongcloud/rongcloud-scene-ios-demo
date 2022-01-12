//
//  RCChatroomSceneInputViewController.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/2.
//

#import <Masonry/Masonry.h>

#import "UIImage+Bundle.h"
#import "HPGrowingTextView.h"
#import "AGEmojiKeyboardView.h"
#import "RCChatroomSceneInputBarConfig.h"
#import "RCChatroomSceneInputViewController.h"

@interface RCChatroomSceneInputViewController () <HPGrowingTextViewDelegate, AGEmojiKeyboardViewDelegate, AGEmojiKeyboardViewDataSource>

@property (nonatomic, weak) id<RCChatroomSceneInputViewControllerDelegate> delegate;
@property (nonatomic, strong) RCChatroomSceneInputBarConfig *config;

@property (nonatomic, strong) UIView *tapDismissView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *emojiView;
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) UIButton *emojiButton;
@property (nonatomic, strong) UIView *containerLineView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, assign) NSInteger hasInputLength;

@end

@implementation RCChatroomSceneInputViewController

- (instancetype)initWithConfig:(RCChatroomSceneInputBarConfig *)config
                 inputDelegate:(id<RCChatroomSceneInputViewControllerDelegate>)delegate {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.config = config;
        self.delegate = delegate;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (UIView *)tapDismissView {
    if (_tapDismissView == nil) {
        _tapDismissView = [[UIView alloc] init];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapDismiss)];
        [_tapDismissView addGestureRecognizer:tap];
    }
    return _tapDismissView;
}

- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = _config.backgroundColor;
    }
    return _containerView;
}

- (UIImageView *)backgroundImageView {
    if (_backgroundImageView == nil) {
        UIImage *image = [UIImage bundleImageNamed:@"input_background"];
        _backgroundImageView = [[UIImageView alloc] initWithImage:image];
    }
    return _backgroundImageView;
}

- (HPGrowingTextView *)textView {
    if (_textView == nil) {
        _textView = [[HPGrowingTextView alloc] init];
        _textView.delegate = self;
        _textView.font = [UIFont systemFontOfSize:_config.inputTextSize];
        _textView.textColor = _config.inputTextColor;
        _textView.maxHeight = _config.inputMaxHeight;
        _textView.minHeight = _config.inputMinHeight;
        _textView.placeholder = _config.inputHint;
        _textView.placeholderColor = _config.inputHintColor;
        _textView.backgroundColor = _config.inputBackgroundColor;
        _textView.layer.cornerRadius = _config.inputCorner;
        _textView.layer.masksToBounds = YES;
        _textView.contentInset = _config.inputInsets;
    }
    return _textView;
}

- (UIView *)emojiView {
    if (_emojiView == nil) {
        _emojiView = [[UIView alloc] init];
    }
    return _emojiView;
}

- (UIButton *)emojiButton {
    if (_emojiButton == nil) {
        _emojiButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *normalImage = [UIImage bundleImageNamed:@"input_emoji"];
        [_emojiButton setImage:normalImage forState:UIControlStateNormal];
        UIImage *selectedImage = [UIImage bundleImageNamed:@"input_keyboard"];
        [_emojiButton setImage:selectedImage forState:UIControlStateSelected];
        [_emojiButton addTarget:self
                         action:@selector(emojiButtonClicked)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiButton;
}

- (UIButton *)sendButton {
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton addTarget:self
                        action:@selector(sendButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
        UIImage *image = [self sendButtonBackgroundImage];
        [_sendButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    return _sendButton;
}

- (UIView *)containerLineView {
    if (_containerLineView) {
        _containerLineView = [[UIView alloc] init];
        _containerLineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    }
    return _containerLineView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tapDismissView];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.backgroundImageView];
    [self.containerView addSubview:self.textView];
    [self.containerView addSubview:self.sendButton];
    [self.containerView addSubview:self.containerLineView];
    
    [self.tapDismissView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_greaterThanOrEqualTo(50);
    }];
    
    [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.containerView);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets contentInset = _config.contentInsets;
        make.left.equalTo(self.containerView).offset(contentInset.left);
        make.top.equalTo(self.containerView).inset(contentInset.top);
        make.bottom.equalTo(self.containerView).inset(contentInset.bottom);
        make.height.mas_equalTo(34);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets contentInset = _config.contentInsets;
        make.right.equalTo(self.containerView).offset(-contentInset.right);
        make.centerY.equalTo(self.containerView);
        make.width.mas_equalTo(55);
        make.height.mas_equalTo(31);
    }];
    
    if (self.config.emojiEnable) {
        [self.containerView addSubview:self.emojiButton];
        [self.emojiButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(30);
            make.centerY.equalTo(self.containerView);
            make.left.equalTo(self.textView.mas_right).offset(12);
            make.right.equalTo(self.sendButton.mas_left).offset(-12);
        }];
    } else {
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.sendButton.mas_left).offset(-12);
        }];
    }
    
    [self.containerLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.containerView);
        make.height.mas_equalTo(1);
    }];
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(keyboardWillChangeFrame:)
                                               name:UIKeyboardWillChangeFrameNotification
                                             object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
    });
}

- (void)handleTapDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)emojiButtonClicked {
    if (self.textView.internalTextView.inputView == nil) {
        if (self.config.inputEmojiView) {
            self.textView.internalTextView.inputView = self.config.inputEmojiView;
        } else {
            AGEmojiKeyboardView *emojiKeyboardView = [[AGEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216) dataSource:self];
            emojiKeyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            emojiKeyboardView.delegate = self;
            self.textView.internalTextView.inputView = emojiKeyboardView;
        }
        self.emojiButton.selected = YES;
    } else {
        self.textView.internalTextView.inputView = nil;
        self.emojiButton.selected = NO;
    }
    [self.textView.internalTextView reloadInputViews];
}

- (void)sendButtonClicked {
    if (self.textView.text.length >= _config.inputTextMaxLength) {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"文字超出限制%zd",_config.inputTextMaxLength] preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertVc animated:NO completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [alertVc dismissViewControllerAnimated:NO completion:nil];
            });
        }];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(inputViewDidClickSendButtonWith:)]) {
        [self.delegate inputViewDidClickSendButtonWith:self.textView.text];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)sendButtonBackgroundImage {
    return [[[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(55, 31)] imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGRect frame = CGRectMake(0, 0, 55, 31);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:15.5];
        CGContextAddPath(context, path.CGPath);
        CGContextClip(context);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CFArrayRef colors = (__bridge CFArrayRef)(@[
            (__bridge id)[UIColor colorWithRed:233 / 255.0 green:43 / 255.0 blue:153 / 255.0 alpha:1.0].CGColor,
            (__bridge id)[UIColor colorWithRed:168 / 255.0 green:53 / 255.0 blue:239 / 255.0 alpha:1.0].CGColor,
        ]);
        CGFloat *locations = {0, 1};
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
        CGContextDrawLinearGradient(context,
                                    gradient,
                                    CGPointMake(27.5, 0),
                                    CGPointMake(27.5, 31),
                                    kCGGradientDrawsBeforeStartLocation);
        CGColorSpaceRelease(colorSpace);
        CGGradientRelease(gradient);
    }];
}

#pragma mark - HPGrowingTextViewDelegate -

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        [self.view layoutIfNeeded];
    });
}

#pragma mark - keyboardWillChangeFrame -

- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo == nil) return;

    NSValue *value = userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = value.CGRectValue;

    CGFloat keyboardHeight = UIScreen.mainScreen.bounds.size.height - endFrame.origin.y;
    if (keyboardHeight > 0) {
        keyboardHeight = keyboardHeight - self.view.safeAreaInsets.bottom;
    }
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-keyboardHeight);
    }];
    [self.view layoutIfNeeded];
}

#pragma mark - AGEmojiKeyboardViewDelegate -

- (void)emojiKeyBoardView:(AGEmojiKeyboardView *)emojiKeyBoardView didUseEmoji:(NSString *)emoji {
    [self.textView.internalTextView insertText:emoji];
}

- (void)emojiKeyBoardViewDidPressBackSpace:(AGEmojiKeyboardView *)emojiKeyBoardView {
    [self.textView.internalTextView deleteBackward];
}

@end
