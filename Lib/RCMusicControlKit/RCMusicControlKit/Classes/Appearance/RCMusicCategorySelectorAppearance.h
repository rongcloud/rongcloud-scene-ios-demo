//
//  RCMusicCategorySelectorAppearance.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/19.
//

#import "RCMusicAppearance.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicCategorySelectorAppearance : RCMusicAppearance
//是否显示指示器
@property (nonatomic, assign) BOOL showIndicator;
//指示器大小
@property (nonatomic, assign) CGSize indicatorSize;
//正常颜色
@property (nonatomic, strong) UIColor *normalTextColor;
//选中颜色
@property (nonatomic, strong) UIColor *selectedTextColor;
//正常字体
@property (nonatomic, strong) UIFont *normalFont;
//选中字体
@property (nonatomic, strong) UIFont *selectedFont;
@end

NS_ASSUME_NONNULL_END
