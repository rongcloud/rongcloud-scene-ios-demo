//
//  RCMusicAppearanceData.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/23.
//

#import <UIKit/UIKit.h>

@class RCMusicAppearanceData;
@class RCMusicModule;
@class RCMusicCategorySelectorData;
@class RCMusicBarItemData;
@class RCMusicMusicControlData;
@class RCMusicMusicListData;
@class RCMusicSoundEffectData;
@class RCMusicToolBarData;
@class RCMusicColor;
@class RCMusicInset;
@class RCMusicSize;
@class RCMusicCategorySelectorLabelAttributes;
@class RCMusicFont;
@class RCMusicMusicListContentLabelAttribute;
@class RCMusicBarItem;

@interface RCMusicAppearanceValue : NSObject
- (nullable id)appearanceValue;
@end

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicAppearanceData : NSObject
- (instancetype)initWithDict:(nullable NSDictionary *)dict;
+ (instancetype)defaultAppearance;
@property (nonatomic, nullable, strong) RCMusicModule *module;
@end

@interface RCMusicModule : NSObject
//顶部工具栏
@property (nonatomic, nullable, strong) RCMusicToolBarData *toolBar;
//工具栏按钮
@property (nonatomic, nullable, strong) RCMusicBarItemData *barItem;
//歌曲类别选择器
@property (nonatomic, nullable, strong) RCMusicCategorySelectorData *categorySelector;
//音乐列表
@property (nonatomic, nullable, strong) RCMusicMusicListData *musicList;
//音乐控制器
@property (nonatomic, nullable, strong) RCMusicMusicControlData *musicControl;
//特效展示栏
@property (nonatomic, nullable, strong) RCMusicSoundEffectData *soundEffect;
@end

//颜色数据
@interface RCMusicColor : RCMusicAppearanceValue
@property (nonatomic, nullable, copy) NSString *red;
@property (nonatomic, nullable, copy) NSString *green;
@property (nonatomic, nullable, copy) NSString *blue;
@property (nonatomic, nullable, copy) NSString *alpha;
@end

//edge数据
@interface RCMusicInset : RCMusicAppearanceValue
@property (nonatomic, nullable, copy) NSString *top;
@property (nonatomic, nullable, copy) NSString *bottom;
@property (nonatomic, nullable, copy) NSString *left;
@property (nonatomic, nullable, copy) NSString *right;
@end

//字体数据 weight == 400 reg  weight == 700 bold
@interface RCMusicFont : RCMusicAppearanceValue
@property (nonatomic, nullable, copy) NSString *size;
@property (nonatomic, nullable, copy) NSString *weight;
@end

//size数据
@interface RCMusicSize : RCMusicAppearanceValue
@property (nonatomic, nullable, copy) NSString *width;
@property (nonatomic, nullable, copy) NSString *height;
@end

//歌单类别选择器 选中字体和选中颜色
@interface RCMusicCategorySelectorLabelAttributes : RCMusicAppearanceValue
@property (nonatomic, nullable, strong) RCMusicFont *normalFont;
@property (nonatomic, nullable, strong) RCMusicFont *selectedFont;
@property (nonatomic, nullable, strong) RCMusicColor *normalColor;
@property (nonatomic, nullable, strong) RCMusicColor *selectedColor;
@end

//歌曲列表文本
@interface RCMusicMusicListContentLabelAttribute : RCMusicAppearanceValue
@property (nonatomic, nullable, strong) RCMusicColor *textColor;
@property (nonatomic, nullable, strong) RCMusicFont *font;
@property (nonatomic, nullable, strong) RCMusicInset *titleInsets;
@property (nonatomic, nullable, copy)   NSString *alignment;
@end

//size数据
@interface RCMusicIcon : NSObject
//本地素材
@property (nonatomic, nullable, copy) NSString *local;
//网络素材
@property (nonatomic, nullable, copy) NSString *remote;
//计算属性，优先返回remote
@property (nonatomic, nullable, copy) NSString *source;
@end


//tool bar item
@interface RCMusicBarItemData : NSObject
//背景颜色
@property (nonatomic, nullable, strong) RCMusicColor *backgroundColor;
//item 大小
@property (nonatomic, nullable, strong) RCMusicSize *size;
//button image 填充方式
@property (nonatomic, nullable, copy)   NSString *contentMode;
// button image inset
@property (nonatomic, nullable, strong) RCMusicInset *contentInset;
@end

@interface RCMusicBarItem : NSObject
@property (nonatomic, nullable, strong) RCMusicIcon *normalImage;
@property (nonatomic, nullable, strong) RCMusicIcon *selectedImage;
@end

//歌单类别选择器
@interface RCMusicCategorySelectorData : NSObject
//背景颜色
@property (nonatomic, nullable, strong) RCMusicColor *backgroundColor;
//是否展示 选中指示器
@property (nonatomic, nullable, copy)   NSString *showIndicator;
//选中指示器 大小
@property (nonatomic, nullable, strong) RCMusicSize *indicatorSize;
//文本属性
@property (nonatomic, nullable, strong) RCMusicCategorySelectorLabelAttributes *labelAttributes;
@end

//music control
@interface RCMusicMusicControlData : NSObject
//背景颜色
@property (nonatomic, nullable, strong) RCMusicColor *backgroundColor;
//slider switch tintColor
@property (nonatomic, nullable, strong) RCMusicColor *tintColor;
//文本颜色
@property (nonatomic, nullable, strong) RCMusicColor *textColor;
//字体
@property (nonatomic, nullable, strong) RCMusicFont *font;
@end

//音乐列表
@interface RCMusicMusicListData : NSObject
//背景颜色
@property (nonatomic, nullable, strong) RCMusicColor *backgroundColor;
//头像大小
@property (nonatomic, nullable, strong) RCMusicSize *avatarSize;
//头像缩进
@property (nonatomic, nullable, strong) RCMusicInset *avatarInsets;
//分割线缩进
@property (nonatomic, nullable, strong) RCMusicInset *separatorInset;
//主标题 文本属性
@property (nonatomic, nullable, strong) RCMusicMusicListContentLabelAttribute *titleAttribute;
//副标题 文本属性
@property (nonatomic, nullable, strong) RCMusicMusicListContentLabelAttribute *contentAttribute;
//小标题 文本属性
@property (nonatomic, nullable, strong) RCMusicMusicListContentLabelAttribute *sizeAttribute;
//是否展示本地上传入口
@property (nonatomic, nullable, strong) NSNumber *turnOnLocalUpload;
@end

//特效列表
@interface RCMusicSoundEffectData : NSObject
//背景颜色
@property (nonatomic, nullable, strong) RCMusicColor *backgroundColor;
//边框颜色
@property (nonatomic, nullable, strong) RCMusicColor *borderColor;
//边框宽度
@property (nonatomic, nullable, copy)   NSString *borderWidth;
//文本颜色
@property (nonatomic, nullable, strong) RCMusicColor *textColor;
//文本字体
@property (nonatomic, nullable, strong) RCMusicFont *font;
@end

//Tool Bar
@interface RCMusicToolBarData : NSObject
//背景颜色
@property (nonatomic, nullable, strong) RCMusicColor *backgroundColor;
//左边距
@property (nonatomic, nullable, copy)   NSString *leading;
//右边距
@property (nonatomic, nullable, copy)   NSString *trailing;
//item 之间的间隔   item|space|item
@property (nonatomic, nullable, copy)   NSString *spacing;
//tool bar 内包含的item
@property (nonatomic, nullable, copy) NSArray<RCMusicBarItem *> *items;

//开启音乐控制功能
@property (nonatomic, nullable, strong) NSNumber *turnOnMusicControl;

//开启声音特效功能
@property (nonatomic, nullable, strong) NSNumber *turnOnSoundEffect;
@end

NS_ASSUME_NONNULL_END
