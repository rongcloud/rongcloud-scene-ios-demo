//
//  UIView+Toast.h
//  RCVoiceRoomCallKit
//
//  Created by shaoshuai on 2021/8/2.
//

#import <UIKit/UIKit.h>
#import <RongCallLib/RongCallLib.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Toast)

- (void)showToast:(NSString *)message;
- (void)toastWhenDisconnect:(RCCallDisconnectReason)reason;

@end

NS_ASSUME_NONNULL_END
