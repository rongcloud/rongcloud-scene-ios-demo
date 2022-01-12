//
//  RCMusicControlAppearance.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/23.
//

#import "RCMusicControlAppearance.h"
#import "RCMUsicColors.h"
#import "RCMusicAppearanceData.h"

#define mca [RCMusicAppearanceData defaultAppearance].module.musicControl

@implementation RCMusicControlAppearance

- (instancetype)init {
    if (self = [super init]) {
        _tintColor = mca.tintColor.appearanceValue ?: mainColor;
        _textColor = mca.textColor.appearanceValue ?: [UIColor whiteColor];
        _font = mca.font.appearanceValue ?: [UIFont systemFontOfSize:14];
    }
    return self;
 }
@end
