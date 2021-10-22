//
//  MHPrintView.h


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MHBeautiesModel;
@protocol MHPrintViewDelegate <NSObject>

- (void)handlePrint:(MHBeautiesModel *)model;

@end

@interface MHPrintView : UIView

@property (nonatomic, weak) id<MHPrintViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
