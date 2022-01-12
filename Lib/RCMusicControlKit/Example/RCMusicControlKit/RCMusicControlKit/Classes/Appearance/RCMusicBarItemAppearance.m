//
//  RCMusicBarItemAppearance.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import "RCMusicBarItemAppearance.h"
#import "RCMusicAppearanceData.h"

#define bia [RCMusicAppearanceData defaultAppearance].module.barItem

@implementation RCMusicBarItemAppearance

- (instancetype)init {
    if (self = [super init]) {
        _size = bia.size ? CGSizeFromString(bia.size.appearanceValue) : CGSizeMake(36, 36);
        _contentMode = bia.contentMode ? bia.contentMode.integerValue : UIViewContentModeScaleAspectFit;
        _contentInset = bia.contentInset ? UIEdgeInsetsFromString(bia.contentInset.appearanceValue) : UIEdgeInsetsZero;
        self.backgroundColor = bia.backgroundColor ? bia.backgroundColor.appearanceValue : [UIColor clearColor];
    }
    return self;
}

@end
