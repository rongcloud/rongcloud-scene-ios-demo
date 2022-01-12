//
//  RCMusicBarItemAppearance.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import "RCMusicAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicBarItemAppearance : RCMusicAppearance
//item size default [36,36]
@property (nonatomic, assign) CGSize size;
//default UIViewContentModeScaleAspectFit
@property (nonatomic, assign) UIViewContentMode contentMode;
//default [0,0,0,0]
@property (nonatomic, assign) UIEdgeInsets contentInset;
@end

NS_ASSUME_NONNULL_END
