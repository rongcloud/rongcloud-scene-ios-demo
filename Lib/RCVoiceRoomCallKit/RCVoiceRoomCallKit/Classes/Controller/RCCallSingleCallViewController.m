//
//  RCCallSingleCallViewController.m
//  RongCallKit
//
//  Created by RongCloud on 16/3/21.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCCallSingleCallViewController.h"
#import "RCCallFloatingBoard.h"
#import "RCCallKitUtility.h"
#import "RCUserInfoCacheManager.h"
#import "RCloudImageView.h"
#import "RCCallUserCallInfoModel.h"
#import "RCCall.h"
#import "RCCXCall.h"

#define currentUserId ([RCIMClient sharedRCIMClient].currentUserInfo.userId)
@interface RCCallSingleCallViewController ()

@property(nonatomic, strong) RCUserInfo *remoteUserInfo;
@property(nonatomic, assign) BOOL isFullScreen;

@end

@implementation RCCallSingleCallViewController

// init
- (instancetype)initWithIncomingCall:(RCCallSession *)callSession {
    return [super initWithIncomingCall:callSession];
}

- (instancetype)initWithOutgoingCall:(NSString *)targetId mediaType:(RCCallMediaType)mediaType {
    return [super initWithOutgoingCall:ConversationType_PRIVATE
                              targetId:targetId
                             mediaType:mediaType
                            userIdList:@[ targetId ]];
}

- (instancetype)initWithActiveCall:(RCCallSession *)callSession {
    return [super initWithActiveCall:callSession];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserInfoUpdate:)
                                                 name:RCKitDispatchUserInfoUpdateNotification
                                               object:nil];

    RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:self.callSession.targetId];
    if (!userInfo) {
        userInfo = [[RCUserInfo alloc] initWithUserId:self.callSession.targetId name:nil portrait:nil];
    }
    self.remoteUserInfo = userInfo;
    [self.remoteNameLabel setText:userInfo.name];
    [self.remotePortraitView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
    self.backgroundView.userInteractionEnabled = YES;
    [self.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundSingleViewClicked)]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.isFullScreen = NO;
    [RCCallKitUtility checkSystemPermission:self.callSession.mediaType success:^{
    } error:^{
        [self hangupButtonClicked];
    }];
}

- (RCloudImageView *)remotePortraitView {
    if (!_remotePortraitView) {
        _remotePortraitView = [[RCloudImageView alloc] init];
        _remotePortraitView.frame = CGRectMake((self.view.frame.size.width - 94) * 0.5, 85, 94, 94);
        [self.view addSubview:_remotePortraitView];
        _remotePortraitView.hidden = YES;
        [_remotePortraitView setPlaceholderImage:[RCCallKitUtility getDefaultPortraitImage]];
        _remotePortraitView.layer.masksToBounds = YES;
        _remotePortraitView.layer.cornerRadius = RCCallHeaderLength/2;
    }
    return _remotePortraitView;
}

- (UILabel *)remoteNameLabel {
    if (!_remoteNameLabel) {
        _remoteNameLabel = [[UILabel alloc] init];
        _remoteNameLabel.backgroundColor = [UIColor clearColor];
        _remoteNameLabel.textColor = [UIColor colorWithRed:0.008 green:0 blue:0.216 alpha:1];
        _remoteNameLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:18];
        _remoteNameLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:_remoteNameLabel];
        _remoteNameLabel.hidden = YES;
    }
    return _remoteNameLabel;
}

- (UIView *)mainVideoView {
    if (!_mainVideoView) {
        _mainVideoView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
        _mainVideoView.backgroundColor = RongVoIPUIColorFromRGB(0x262e42);

        [self.backgroundView addSubview:_mainVideoView];
        _mainVideoView.hidden = YES;
    }
    return _mainVideoView;
}

- (UIView *)subVideoView {
    if (!_subVideoView) {
        _subVideoView = [[UIView alloc] init];
        _subVideoView.backgroundColor = [UIColor blackColor];
        _subVideoView.layer.borderWidth = 1;
        _subVideoView.layer.borderColor = [[UIColor whiteColor] CGColor];

        [self.view addSubview:_subVideoView];
        _subVideoView.hidden = YES;

        UITapGestureRecognizer *tap =
            [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subVideoViewClicked)];
        [_subVideoView addGestureRecognizer:tap];
    }
    return _subVideoView;
}

- (void)subVideoViewClicked {
    if ([self.remoteUserInfo.userId isEqualToString:self.callSession.targetId]) {
        RCUserInfo *userInfo = [RCIMClient sharedRCIMClient].currentUserInfo;

        self.remoteUserInfo = userInfo;
        [self.remoteNameLabel setText:userInfo.name];
        [self.remotePortraitView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];

        [self.callSession setVideoView:self.mainVideoView userId:self.remoteUserInfo.userId];
        [self.callSession setVideoView:self.subVideoView userId:self.callSession.targetId];
    } else {
        RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:self.callSession.targetId];
        if (!userInfo) {
            userInfo = [[RCUserInfo alloc] initWithUserId:self.callSession.targetId name:nil portrait:nil];
        }
        self.remoteUserInfo = userInfo;
        [self.remoteNameLabel setText:userInfo.name];
        [self.remotePortraitView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];

        [self.callSession setVideoView:self.subVideoView userId:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
        [self.callSession setVideoView:self.mainVideoView userId:self.remoteUserInfo.userId];
    }
}

- (void)didTapCameraCloseButton
{
    [self resetLayout:self.callSession.isMultiCall
            mediaType:RCCallMediaAudio
           callStatus:self.callSession.callStatus];
}

- (RCCallUserCallInfoModel *)generateUserModel:(NSString *)userId {
    RCCallUserCallInfoModel *userModel = [[RCCallUserCallInfoModel alloc] init];
    userModel.userId = userId;
    userModel.userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:userId];
    
    if ([userId isEqualToString:currentUserId]) {
        userModel.profile = self.callSession.myProfile;
    } else {
        for (RCCallUserProfile *userProfile in self.callSession.userProfileList) {
            if ([userProfile.userId isEqualToString:userId]) {
                userModel.profile = userProfile;
                break;
            }
        }
    }
    
    return userModel;
}

- (void)resetLayout:(BOOL)isMultiCall mediaType:(RCCallMediaType)mediaType callStatus:(RCCallStatus)sessionCallStatus {
    [super resetLayout:isMultiCall mediaType:mediaType callStatus:sessionCallStatus];

    RCCallStatus callStatus = sessionCallStatus;
    if ((callStatus == RCCallIncoming || callStatus == RCCallRinging) && [RCCXCall sharedInstance].acceptedFromCallKit) {
        callStatus = RCCallActive;
        [RCCXCall sharedInstance].acceptedFromCallKit = NO;
    }

    [self setAllHidden];
    
    if (mediaType == RCCallMediaAudio) {
        [self setupAudioUI:callStatus];
    } else {
        [self setupVideoUI:callStatus];
    }
    
    self.minimizeButton.hidden = NO;
    UIImage *minimizeImage = self.blurView.hidden ?
    [RCCallKitUtility imageFromVoIPBundle:@"voip/minimize_light.png"] :
    [RCCallKitUtility imageFromVoIPBundle:@"voip/minimize_dark.png"];
    [self.minimizeButton setImage:minimizeImage forState:UIControlStateNormal];
    [self.minimizeButton setImage:minimizeImage forState:UIControlStateHighlighted];
    
    if (self.callSession.callStatus == RCCallIncoming || self.callSession.callStatus == RCCallRinging) {
        if (self.callSession.mediaType == RCCallMediaAudio) {
            self.tipsLabel.text = RCCallKitLocalizedString(@"VoIPAudioCallIncoming");
        } else {
            self.tipsLabel.text = RCCallKitLocalizedString(@"VoIPVideoCallIncoming");
        }
    }
    
    switch (callStatus) {
        case RCCallDialing:
            [self.hangupButton setTitle:RCCallKitLocalizedString(@"Cancel")
                               forState:UIControlStateNormal];
            break;
        case RCCallIncoming:
        case RCCallRinging:
        case RCCallActive:
            [self.hangupButton setTitle:RCCallKitLocalizedString(@"VoIPCallHangup")
                               forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    [self resetRemoteUserInfoIfNeed];
}

- (void)setupVideoUI:(RCCallStatus)callStatus {
    [self.acceptButton setImage:[RCCallKitUtility imageFromVoIPBundle:@"voip/answervideo.png"]
                       forState:UIControlStateNormal];
    [self.acceptButton setImage:[RCCallKitUtility imageFromVoIPBundle:@"voip/answervideo_hover.png"]
                       forState:UIControlStateHighlighted];
    
    switch (callStatus) {
        case RCCallDialing:
            [self.remoteNameLabel setText:self.remoteUserInfo.name];
            break;
        case RCCallIncoming:
        case RCCallRinging:
            [self.remoteNameLabel setText:self.remoteUserInfo.name];
            break;
        default:
            break;
    }
    
    ///视频流展示
    switch (callStatus) {
        case RCCallDialing:
            self.mainVideoView.hidden = NO;
            [self.callSession setVideoView:self.mainVideoView
                                    userId:self.callSession.caller];
            break;
        case RCCallActive:
            self.mainVideoView.hidden = NO;
            [self.callSession setVideoView:self.mainVideoView
                                    userId:self.callSession.targetId];
            break;
        case RCCallHangup:
            self.mainVideoView.hidden = NO;
        default:
            break;
    }

    ///远端信息展示
    switch (callStatus) {
        case RCCallDialing:
        case RCCallIncoming:
        case RCCallRinging:
            self.remotePortraitView.hidden = NO;
            self.remoteNameLabel.hidden = NO;
            self.tipsLabel.hidden = NO;
            break;
        case RCCallActive:
            self.remoteNameLabel.hidden = NO;
            self.timeLabel.hidden = NO;
            break;
        default:
            break;
    }
    
    ///信息展示位置
    switch (callStatus) {
        case RCCallDialing:
        case RCCallRinging:
        case RCCallIncoming:
            self.remoteNameLabel.frame = CGRectMake((self.view.frame.size.width - RCCallNameLabelWidth) / 2,
                                                    CGRectGetMaxY(self.remotePortraitView.frame) + 20,
                                                    RCCallNameLabelWidth,
                                                    RCCallMiniLabelHeight + 8);
            self.tipsLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                              CGRectGetMaxY(self.remoteNameLabel.frame) + 14,
                                              self.view.frame.size.width - RCCallHorizontalMargin * 2, 20);
            break;
        case RCCallActive:
            self.remoteNameLabel.frame = CGRectMake((self.view.frame.size.width - RCCallNameLabelWidth) * 0.5,
                                                    self.view.safeAreaTop,
                                                    RCCallNameLabelWidth,
                                                    RCCallMiniLabelHeight + 8);
            self.timeLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                              CGRectGetMaxY(self.remoteNameLabel.frame) + 8,
                                              self.view.frame.size.width - RCCallHorizontalMargin * 2,
                                              20);
            break;
        default:
            break;
    }
    
    UIColor *darkColor = [UIColor colorWithRed:0.008 green:0 blue:0.216 alpha:1];
    UIColor *lightColor = [UIColor colorWithRed:0.733 green:0.753 blue:0.792 alpha:1];
    
    ///信息颜色
    switch (callStatus) {
        case RCCallRinging:
        case RCCallIncoming:
            self.remoteNameLabel.textColor = darkColor;
            self.tipsLabel.textColor = lightColor;
            break;
        case RCCallDialing:
        case RCCallActive:
            self.remoteNameLabel.textColor = [UIColor whiteColor];
            self.tipsLabel.textColor = [UIColor whiteColor];
            break;
        default:
            break;
    }
    self.timeLabel.textColor = [UIColor whiteColor];
    
    ///按钮信息
    [self.hangupButton setTitle:RCCallKitLocalizedString(@"VoIPCallHangup") forState:UIControlStateNormal];
    switch (callStatus) {
        case RCCallDialing:
        {
            CGFloat originalX = self.view.frame.size.width - RCCallHorizontalMiddleMargin - RCCallCustomButtonLength;
            CGFloat originalY = self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - 13 - RCCallCustomButtonLength - self.view.safeAreaBottom;
            self.cameraCloseButton.frame = CGRectMake(originalX,
                                                      originalY,
                                                      RCCallCustomButtonLength,
                                                      RCCallCustomButtonLength);
            self.cameraCloseButton.hidden = NO;
            self.speakerButton.hidden = YES;
            [self.hangupButton setTitle:RCCallKitLocalizedString(@"Cancel") forState:UIControlStateNormal];
        }
            break;
        case RCCallIncoming:
        case RCCallRinging:
            [self.hangupButton setTitleColor:darkColor forState:UIControlStateNormal];
            [self.acceptButton setTitleColor:darkColor forState:UIControlStateNormal];
            break;
        case RCCallActive:
            [self.hangupButton setTitleColor:lightColor forState:UIControlStateNormal];
            break;
        default:
            break;
    }
    
    if (callStatus == RCCallActive) {
        CGFloat originalX = self.view.frame.size.width - RCCallHeaderLength - RCCallHorizontalMargin / 2;
        CGFloat originalY = 45 + self.view.safeAreaTop;
        if ([self isLandscape]) {
            self.subVideoView.frame = CGRectMake(originalX, originalY, RCCallHeaderLength * 1.5, RCCallHeaderLength);
        } else {
            self.subVideoView.frame = CGRectMake(originalX, originalY, RCCallHeaderLength, RCCallHeaderLength * 1.5);
        }
        self.subVideoView.hidden = NO;
        [self.callSession setVideoView:self.subVideoView
                                userId:[RCIMClient sharedRCIMClient].currentUserInfo.userId];
    }

    ///浅色背景
    switch (callStatus) {
        case RCCallRinging:
        case RCCallIncoming:
            self.blurView.hidden = YES;
            break;
        default:
            self.blurView.hidden = YES;
            break;
    }
    
    [self.cameraCloseButton setTMPEnabled:callStatus == RCCallActive];
}

- (void)setupAudioUI:(RCCallStatus)callStatus {
    [self.acceptButton setImage:[RCCallKitUtility imageFromVoIPBundle:@"voip/answer.png"]
                       forState:UIControlStateNormal];
    [self.acceptButton setImage:[RCCallKitUtility imageFromVoIPBundle:@"voip/answer_hover.png"]
                       forState:UIControlStateHighlighted];
    
    self.remotePortraitView.hidden = NO;
    self.remoteNameLabel.hidden = NO;
    self.blurView.hidden = NO;
    
    switch (callStatus) {
        case RCCallDialing:
        case RCCallRinging:
        case RCCallIncoming:
            self.tipsLabel.hidden = NO;
            break;
        case RCCallActive:
            self.timeLabel.hidden = NO;
            break;
        default:
            break;
    }
    
    UIColor *darkColor = [UIColor colorWithRed:0.008 green:0 blue:0.216 alpha:1];
    UIColor *lightColor = [UIColor colorWithRed:0.733 green:0.753 blue:0.792 alpha:1];
    
    self.remoteNameLabel.textColor = darkColor;
    self.remoteNameLabel.frame = CGRectMake((self.view.frame.size.width - RCCallNameLabelWidth) / 2,
                                            CGRectGetMaxY(self.remotePortraitView.frame) + 20,
                                            RCCallNameLabelWidth,
                                            RCCallMiniLabelHeight + 8);
    
    self.tipsLabel.textColor = lightColor;
    self.tipsLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                      CGRectGetMaxY(self.remoteNameLabel.frame) + 14,
                                      self.view.frame.size.width - RCCallHorizontalMargin * 2, 20);
    
    self.timeLabel.textColor = darkColor;
    self.timeLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                      CGRectGetMaxY(self.remoteNameLabel.frame) + 14,
                                      self.view.frame.size.width - RCCallHorizontalMargin * 2,
                                      20);

    [self.muteButton setTitleColor:darkColor forState:UIControlStateNormal];
    [self.hangupButton setTitleColor:darkColor forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:darkColor forState:UIControlStateNormal];
    [self.acceptButton setTitleColor:darkColor forState:UIControlStateNormal];
}

- (void)resetRemoteUserInfoIfNeed {
    if (![self.remoteUserInfo.userId isEqualToString:self.callSession.targetId]) {
        RCUserInfo *userInfo = [[RCUserInfoCacheManager sharedManager] getUserInfo:self.callSession.targetId];
        if (!userInfo) {
            userInfo = [[RCUserInfo alloc] initWithUserId:self.callSession.targetId name:nil portrait:nil];
        }
        self.remoteUserInfo = userInfo;
        [self.remoteNameLabel setText:userInfo.name];
        [self.remotePortraitView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
    }
}

- (void)setAllHidden {
    self.blurView.hidden = YES;
    self.mainVideoView.hidden = YES;
    self.subVideoView.hidden = YES;
    self.remotePortraitView.hidden = YES;
    self.remoteNameLabel.hidden = YES;
    self.tipsLabel.hidden = YES;
    self.timeLabel.hidden = YES;
}

- (BOOL)isLandscape {
    return [RCCallKitUtility isLandscape] &&
    [self isSupportOrientation:(UIInterfaceOrientation)[UIDevice currentDevice].orientation];
}

- (BOOL)isSupportOrientation:(UIInterfaceOrientation)orientation {
    UIWindow *keyWindow;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (!window.isKeyWindow) continue;
        keyWindow = window;
    }
    if (keyWindow == nil) return NO;
    UIInterfaceOrientationMask mask = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:keyWindow];
    return mask & (1 << orientation);
}

#pragma mark - UserInfo Update
- (void)onUserInfoUpdate:(NSNotification *)notification {
    NSDictionary *userInfoDic = notification.object;
    if (userInfoDic == nil || ![userInfoDic isKindOfClass:[NSDictionary class]]) return;
    NSString *updateUserId = userInfoDic[@"userId"];
    RCUserInfo *updateUserInfo = userInfoDic[@"userInfo"];

    if ([updateUserId isEqualToString:self.remoteUserInfo.userId]) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.remoteUserInfo = updateUserInfo;
            [weakSelf.remoteNameLabel setText:updateUserInfo.name];
            [weakSelf.remotePortraitView setImageURL:[NSURL URLWithString:updateUserInfo.portraitUri]];
        });
    }
}

- (void)backgroundSingleViewClicked {
    if (self.callSession.mediaType == RCCallMediaVideo && self.callSession.callStatus == RCCallActive) {
        self.isFullScreen = !self.isFullScreen;
        [self setNeedsStatusBarAppearanceUpdate];
        
        if (self.callSession.mediaType == RCCallMediaVideo
            && self.callSession.callStatus == RCCallActive) {
            self.minimizeButton.hidden = self.isFullScreen;
            self.whiteBoardButton.hidden = self.isFullScreen;
            self.cameraSwitchButton.hidden = self.isFullScreen;
            self.muteButton.hidden = self.isFullScreen;
            self.hangupButton.hidden = self.isFullScreen;
            self.cameraCloseButton.hidden = self.isFullScreen;
            self.remoteNameLabel.hidden = self.isFullScreen;
            self.timeLabel.hidden = self.isFullScreen;
            self.signalImageView.hidden = self.isFullScreen;
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.isFullScreen;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
