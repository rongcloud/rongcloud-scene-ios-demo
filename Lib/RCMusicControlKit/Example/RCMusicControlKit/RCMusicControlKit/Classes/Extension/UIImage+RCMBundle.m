//
//  UIImage+RCMBundle.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import "UIImage+RCMBundle.h"

@implementation UIImage (RCMBundle)
+ (UIImage *)rcm_imageNamed:(NSString *)name {
    UIImage *image = nil;
    //TODO
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *bundlePath = [resourcePath stringByAppendingPathComponent:@"RCMusicSource.bundle"];
    NSString *fullPath = [bundlePath stringByAppendingPathComponent:name];;
    image = [[UIImage alloc] initWithContentsOfFile:fullPath];
    return image;
}

@end
