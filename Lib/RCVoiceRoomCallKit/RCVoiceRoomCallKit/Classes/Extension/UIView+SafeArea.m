//
//  UIView+SafeArea.m
//  RCVoiceRoomCallKit
//
//  Created by shaoshuai on 2021/7/6.
//

#import "UIView+SafeArea.h"

@implementation UIView (SafeArea)

- (UIWindow *)keyWindow {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (window.isKeyWindow) return window;
    }
    return [[UIWindow alloc] init];
}

- (CGFloat)safeAreaTop {
    if (@available(iOS 11.0, *)) {
        return [self keyWindow].safeAreaInsets.top;
    }
    return 0;
}

- (CGFloat)safeAreaBottom {
    if (@available(iOS 11.0, *)) {
        return [self keyWindow].safeAreaInsets.bottom;
    }
    return 0;
}

@end
