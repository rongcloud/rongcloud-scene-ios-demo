//
//  RCMusicSoundEffectAppearance.m
//  RCE
//
//  Created by xuefeng on 2021/11/26.
//

#import "RCMusicSoundEffectAppearance.h"
#import "RCMusicAppearanceData.h"

#define sea [RCMusicAppearanceData defaultAppearance].module.soundEffect
@implementation RCMusicSoundEffectAppearance
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = sea.backgroundColor.appearanceValue ?: [[UIColor whiteColor] colorWithAlphaComponent:0.16];
        _textColor = sea.textColor.appearanceValue ?: [UIColor colorWithRed:239/255.0 green:73/255.0 blue:154/255.0 alpha:1];
        _borderColor = sea.borderColor.appearanceValue ?: [UIColor colorWithRed:239/255.0 green:73/255.0 blue:154/255.0 alpha:1];
        _borderWidth = [sea.borderWidth floatValue];
        _font = sea.font.appearanceValue ?: [UIFont systemFontOfSize:14];
    }
    return self;
}
@end
