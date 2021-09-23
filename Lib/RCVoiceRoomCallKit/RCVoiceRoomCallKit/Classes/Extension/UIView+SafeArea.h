//
//  UIView+SafeArea.h
//  RCVoiceRoomCallKit
//
//  Created by shaoshuai on 2021/7/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SafeArea)

- (CGFloat)safeAreaTop;
- (CGFloat)safeAreaBottom;

@end

NS_ASSUME_NONNULL_END
