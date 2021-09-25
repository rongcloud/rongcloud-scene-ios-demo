//
//  RCCallBaseViewController+Toast.h
//  RCVoiceRoomCallKit
//
//  Created by shaoshuai on 2021/7/7.
//

#import "RCCallBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCCallBaseViewController (Toast)

- (void)showToast:(NSString *)message;
- (void)toastWhenDisconnect:(RCCallDisconnectReason)reason;

@end

NS_ASSUME_NONNULL_END
