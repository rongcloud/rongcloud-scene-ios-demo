//
//  RCMusicCategorySelectorAppearance.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/19.
//

#import "RCMusicCategorySelectorAppearance.h"
#import "UIColor+RCMHex.h"
#import "RCMusicAppearanceData.h"

#define cta [RCMusicAppearanceData defaultAppearance].module.categorySelector

@implementation RCMusicCategorySelectorAppearance
- (instancetype)init {
    if (self = [super init]) {
        self.normalTextColor = cta.labelAttributes.normalColor.appearanceValue ?: [UIColor whiteColor];
        self.selectedTextColor = cta.labelAttributes.selectedColor.appearanceValue ?: [UIColor rcmColorFromHexString:@"#EF499A"];
        self.normalFont = cta.labelAttributes.normalFont.appearanceValue ?: [UIFont systemFontOfSize:11];
        self.selectedFont = cta.labelAttributes.selectedFont.appearanceValue ?: [UIFont boldSystemFontOfSize:12];
        self.indicatorSize = cta.indicatorSize.appearanceValue ? CGSizeFromString(cta.indicatorSize.appearanceValue) : CGSizeMake(20, 2);
        self.showIndicator = cta.showIndicator.boolValue;
    }
    return self;
}

@end
