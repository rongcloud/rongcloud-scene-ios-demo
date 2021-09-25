//
//  RCCallBaseViewController+Toast.m
//  RCVoiceRoomCallKit
//
//  Created by shaoshuai on 2021/7/7.
//

#import "RCCallBaseViewController+Toast.h"

@implementation RCCallBaseViewController (Toast)

- (void)showToast:(NSString *)message {
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:message attributes:@{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont systemFontOfSize:16]
    }];
    CGFloat messageHeight = 42;
    CGFloat messageWeight = [attributeString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, messageHeight)
                                                          options:0
                                                          context:nil].size.width + 16;
    CGFloat originalX = (self.view.frame.size.width - messageWeight) * 0.5;
    CGFloat originalY = CGRectGetMinY(self.hangupButton.frame) - 30 - messageHeight;
    CGRect frame = CGRectMake(originalX, originalY, messageWeight, messageHeight);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = attributeString;
    label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    label.layer.cornerRadius = 6;
    label.layer.masksToBounds = true;
    [self.view addSubview:label];
    [UIView animateWithDuration:0.3 delay:1.5 options:0 animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (void)toastWhenDisconnect:(RCCallDisconnectReason)reason {
    switch (reason) {
        case RCCallDisconnectReasonCancel:
            [self showToast:@"已取消"];
            break;
        case RCCallDisconnectReasonReject:
            [self showToast:@"已拒绝"];
            break;
        case RCCallDisconnectReasonHangup:
        case RCCallDisconnectReasonRemoteHangup:
            [self showToast:@"通话结束"];
            break;
        case RCCallDisconnectReasonBusyLine:
            [self showToast:@"忙碌中"];
            break;
        case RCCallDisconnectReasonNoResponse:
            [self showToast:@"未接听"];
            break;
        case RCCallDisconnectReasonEngineUnsupported:
            [self showToast:@"不支持当前引擎"];
            break;
        case RCCallDisconnectReasonNetworkError:
            [self showToast:@"网络出错"];
            break;
        case RCCallDisconnectReasonRemoteCancel:
            [self showToast:@"对方已取消"];
            break;
        case RCCallDisconnectReasonRemoteReject:
            [self showToast:@"对方已拒绝"];
            break;
        case RCCallDisconnectReasonRemoteBusyLine:
            [self showToast:@"对方忙碌中"];
            break;
        case RCCallDisconnectReasonRemoteNoResponse:
            [self showToast:@"对方未接听"];
            break;
        case RCCallDisconnectReasonRemoteEngineUnsupported:
            [self showToast:@"对方不支持当前引擎"];
            break;
        case RCCallDisconnectReasonRemoteNetworkError:
            [self showToast:@"对方网络出错"];
            break;
        case RCCallDisconnectReasonAcceptByOtherClient:
            [self showToast:@"其它端已接听"];
            break;
        case RCCallDisconnectReasonAddToBlackList:
            [self showToast:@"您已被加入黑名单"];
            break;
        case RCCallDisconnectReasonDegrade:
            [self showToast:@"您已被降级为观察者"];
            break;
        case RCCallDisconnectReasonKickedByServer:
            [self showToast:@"禁止通话"];
            break;
        case RCCallDisconnectReasonMediaServerClosed:
            [self showToast:@"音视频服务已关闭"];
            break;
        default:
            break;
    }
}

@end
