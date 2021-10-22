//
//  MHBeautyAssembleView.h


#import <UIKit/UIKit.h>

#import "MHBeautiesModel.h"
#import "MHFilterModel.h"
//@class MHBeautiesModel;
NS_ASSUME_NONNULL_BEGIN
@protocol MHBeautyAssembleViewDelegate <NSObject>
@required
/// 美颜
/// @param type 美颜类型：美白，磨皮，红润
/// @param beautyLevel 美颜参数，0-1，数值越大，效果越明显
- (void)handleBeautyWithType:(NSInteger)type level:(CGFloat)beautyLevel;

/**
 一键美颜

 @param model 一键美颜模型
 */
- (void)handleQuickBeautyValue:(MHBeautiesModel *)model;

- (void)handleQuickBeautyWithSliderValue:(NSInteger)value quickBeautyModel:(MHBeautiesModel *)model;

/**
 美型

 @param type 美型类型
 @param value 数值
 */
- (void)handleFaceBeautyWithType:(NSInteger)type sliderValue:(NSInteger)value;

/**
 滤镜

 @param filter 滤镜
 */
- (void)handleFiltersEffectWithType:(NSInteger)filter withFilterName:(NSString *)filterName;

@end

@interface MHBeautyAssembleView : UIView

@property (nonatomic, weak) id<MHBeautyAssembleViewDelegate> delegate;

- (void)configureUI;
- (void)configureSlider;

@end

NS_ASSUME_NONNULL_END
