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

    NSBundle *bundle = [NSBundle bundleForClass:NSClassFromString(@"RCMusicEngine")];
    
    NSString *resourcePath = [bundle resourcePath];
    
    NSString *RCMusicControlKit = [resourcePath stringByAppendingPathComponent:@"RCMusicControlKit.bundle"];
    
    NSString *RCMusicSource = [RCMusicControlKit stringByAppendingPathComponent:@"RCMusicSource.bundle"];
    
    NSString *path = [RCMusicSource stringByAppendingPathComponent:name];;
    
    image = [[UIImage alloc] initWithContentsOfFile:path];
    
    return image;
}

@end
