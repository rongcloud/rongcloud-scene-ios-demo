//
//  UIColor+RCMHex.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (RCMHex)
+ (UIColor *)rcmColorFromHexString:(NSString *)hexString;
@end

NS_ASSUME_NONNULL_END
