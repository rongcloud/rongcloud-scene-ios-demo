//
//  RCMusicListAppearance.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/17.
//

#import "RCMusicListAppearance.h"
#import "RCMusicAppearanceData.h"

#define mla [RCMusicAppearanceData defaultAppearance].module.musicList

@implementation RCMusicListAppearance

- (instancetype)init {
    if (self = [super init]) {
        _avatarSize = mla.avatarSize ? CGSizeFromString(mla.avatarSize.appearanceValue) : CGSizeMake(44, 44);
        _avatarInsets = mla.avatarInsets ? UIEdgeInsetsFromString(mla.avatarInsets.appearanceValue) : UIEdgeInsetsZero;
        
        _separatorInset = mla.separatorInset ? UIEdgeInsetsFromString(mla.separatorInset.appearanceValue) : UIEdgeInsetsMake(0, 74, 0, 0);
        _titleLabelTextColor = mla.titleAttribute.textColor.appearanceValue ?: [UIColor whiteColor];
        _titleLabelFont = mla.titleAttribute.font.appearanceValue ?: [UIFont boldSystemFontOfSize:15];
        _titleLabelTextAlignment = mla.titleAttribute.alignment.integerValue;
        _titleLabelEdgeInsets = mla.titleAttribute.titleInsets.appearanceValue ? UIEdgeInsetsFromString(mla.titleAttribute.titleInsets.appearanceValue) : UIEdgeInsetsZero;
        _subTitleLabelTextColor =  mla.contentAttribute.textColor.appearanceValue ?: [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _subTitleLabelFont = mla.contentAttribute.font.appearanceValue ?: [UIFont systemFontOfSize:12];
        _subTitleLabelTextAlignment = mla.contentAttribute.alignment.integerValue;
        _subTitleLabelEdgeInsets = mla.contentAttribute.titleInsets.appearanceValue ? UIEdgeInsetsFromString(mla.contentAttribute.titleInsets.appearanceValue) : UIEdgeInsetsZero;
        
        _fileSizeLabelTextColor =  mla.sizeAttribute.textColor.appearanceValue ?: [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _fileSizeLabelFont = mla.sizeAttribute.font.appearanceValue ?: [UIFont systemFontOfSize:12];
        _fileSizeLabelTextAlignment = mla.sizeAttribute.alignment.integerValue;
        _fileSizeLabelEdgeInsets = mla.sizeAttribute.titleInsets.appearanceValue ? UIEdgeInsetsFromString(mla.sizeAttribute.titleInsets.appearanceValue) : UIEdgeInsetsZero;
        _turnOnLocalUpload = mla.turnOnLocalUpload ? [mla.turnOnLocalUpload boolValue] : YES;
        
    }
    return self;
}
@end
