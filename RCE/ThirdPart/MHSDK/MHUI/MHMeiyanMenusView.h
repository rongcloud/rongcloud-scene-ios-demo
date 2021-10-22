//
//  MHMeiyanMenusView.h

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    RCMHBeautyActionSwitch  = 0,
    RCMHBeautyActionSticker = 1,
    RCMHBeautyActionRetouch = 2,
    RCMHBeautyActionMakeup  = 3,
    RCMHBeautyActionEffect  = 4,
} RCMHBeautyAction;

@class MHMeiyanMenusView;
@protocol MHMeiyanMenusViewDelegate <NSObject>
@optional
- (void)view:(MHMeiyanMenusView *)view didClick:(RCMHBeautyAction)action;
@end

@class MHBeautyManager;

@interface MHMeiyanMenusView : UIView

/// 初始化美颜菜单
/// @param manager  美颜管理器，完成初始化后传入
/// @param delegate  事件回调
- (instancetype)initWithManager:(MHBeautyManager *)manager
                       delegate:(id<MHMeiyanMenusViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
