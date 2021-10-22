//
//  MHSpecificAssembleView.h


#import <UIKit/UIKit.h>
#import "StickerDataListModel.h"
@class MHBeautiesModel;
NS_ASSUME_NONNULL_BEGIN
@protocol MHSpecificAssembleViewDelegate <NSObject>

/**
 特性

 @param type 特性类型
 */
- (void)handleSpecificWithType:(NSInteger)type;

/**
 水印

 @param model 水印数据模型
 */
- (void)handleWatermarkWithModel:(MHBeautiesModel *)model;
/**
 动作识别
 */
- (void)handleSpecificStickerActionEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model action:(int)action;

/**
 哈哈镜
 */
- (void)handleMagnityWithType:(NSInteger)type;

@end

@interface MHSpecificAssembleView : UIView

@property (nonatomic, weak) id<MHSpecificAssembleViewDelegate> delegate;

- (void)getActionSource;
- (void)clearAllActionEffects;

@end

NS_ASSUME_NONNULL_END
