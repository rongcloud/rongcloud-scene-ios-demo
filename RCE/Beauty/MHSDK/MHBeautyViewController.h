//
//  MHBeautyViewController.h
//  RCE
//
//  Created by shaoshuai on 2022/1/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RCMHBeautyType) {
    RCMHBeautyTypeSticker,
    RCMHBeautyTypeMakeup,
    RCMHBeautyTypeRetouch,
    RCMHBeautyTypeEffect,
};

@class MHBeautyManager;

@interface MHBeautyViewController : UIViewController

/// 初始化美颜控制器
/// @param manager  美颜管理器，完成初始化后传入
- (instancetype)initWithManager:(MHBeautyManager *)manager;

- (void)showItem:(RCMHBeautyType)item;

- (void)appleDefaultValues;

@end

NS_ASSUME_NONNULL_END
