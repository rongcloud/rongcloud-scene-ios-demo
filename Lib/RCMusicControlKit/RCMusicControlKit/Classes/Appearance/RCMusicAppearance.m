//
//  RCMusicAppearance.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/17.
//

#import "RCMusicAppearance.h"
#import "UIColor+RCMHex.h"
#import "RCMusicColors.h"
#import "RCMusicAppearanceData.h"

@implementation RCMusicAppearance

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [self init]) {}
    return self;
}
- (instancetype)init {
    if (self = [super init]) {
        //设置默认颜色
        _backgroundColor = mainColor;
    }
    return self;
}
@end
