//
//  UIImage+Bundle.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/2.
//



NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Bundle)

/// 通过名字获取png图片，不需要带.png
/// @param name 图片名称
+ (instancetype)bundleImageNamed:(NSString *)name;

+ (instancetype)bundleImageNamed:(NSString *)name extention:(NSString *)extension;

@end

NS_ASSUME_NONNULL_END
