//
//  UIImage+Bundle.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/2.
//

#import "UIImage+Bundle.h"
#import "RCChatroomSceneConstants.h"
@implementation UIImage (Bundle)

+ (instancetype)bundleImageNamed:(NSString *)name {
    return [UIImage bundleImageNamed:name extention:@"png"];
}

+ (instancetype)bundleImageNamed:(NSString *)name extention:(NSString *)extension {
    NSBundle *frameworkBundle = [NSBundle bundleForClass:NSClassFromString(@"RCChatroomSceneToolBar")];
    NSString *resourceBundlePath = [frameworkBundle pathForResource:RCChatroomSceneBundleName ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *path = [resourceBundle pathForResource:name ofType:extension inDirectory:@"images"];
    return [UIImage imageWithContentsOfFile:path];
}

@end
