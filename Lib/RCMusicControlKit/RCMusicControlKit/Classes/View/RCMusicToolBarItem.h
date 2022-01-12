//
//  RCMusicToolBarItem.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicToolBarItem : UIView

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign, readonly, getter=isRecord) BOOL record;

@property (nonatomic, assign, getter=isSelected) BOOL selected;

- (instancetype)initWithNormalImage:(nullable NSString *)normalImage
                      selectedImage:(nullable NSString *)selectedImage
                             record:(BOOL)record
                             target:(nullable id<NSObject>)target
                             action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END
