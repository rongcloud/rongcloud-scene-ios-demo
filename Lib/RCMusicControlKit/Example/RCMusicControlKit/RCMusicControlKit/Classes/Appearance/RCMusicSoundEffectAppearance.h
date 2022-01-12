//
//  RCMusicSoundEffectAppearance.h
//  RCE
//
//  Created by xuefeng on 2021/11/26.
//

#import "RCMusicAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicSoundEffectAppearance : RCMusicAppearance
//文本颜色 r239 g73 b154
@property (nonatomic, strong) UIColor *textColor;
//边框颜色 r239 g73 b154
@property (nonatomic, strong) UIColor *borderColor;
//边框宽度 14
@property (nonatomic, assign) CGFloat borderWidth;
//字体  default system 14
@property (nonatomic, strong) UIFont *font;
@end

NS_ASSUME_NONNULL_END
