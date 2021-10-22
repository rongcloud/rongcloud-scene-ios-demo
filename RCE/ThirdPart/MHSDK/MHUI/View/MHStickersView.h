//MHStickersView.h
//贴纸UI


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MHStickersViewDelegate <NSObject>

- (void)handleStickerEffect:(NSString *)stickerContent
                  withLevel:(NSInteger)level;

@end

@interface MHStickersView : UIView

@property (nonatomic, weak) id<MHStickersViewDelegate> delegate;

- (void)configureStickerTypes;
- (void)clearStikerUI;

@end

NS_ASSUME_NONNULL_END
