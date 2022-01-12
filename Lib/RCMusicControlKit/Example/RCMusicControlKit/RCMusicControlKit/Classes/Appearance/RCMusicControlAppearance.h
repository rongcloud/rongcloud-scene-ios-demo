//
//  RCMusicControlAppearance.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/23.
//

#import "RCMusicAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicControlAppearance : RCMusicAppearance
//色调 default 49388E
@property (nonatomic, strong) UIColor *tintColor;
//计算属性
// default white
@property (nonatomic, strong) UIColor *textColor;

//default system 14
@property (nonatomic, strong) UIFont *font;
@end

NS_ASSUME_NONNULL_END
