//
//  UIImage+RCMBundle.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (RCMBundle)
// full name  ex. image.png  image.jpg
+ (UIImage *)rcm_imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
