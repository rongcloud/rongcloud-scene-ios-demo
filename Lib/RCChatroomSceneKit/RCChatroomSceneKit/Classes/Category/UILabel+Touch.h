//
//  UILabel+Touch.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//@protocol UILabelTouchDelegate <NSObject>
//
//- (void)didClick:(NSString *)eventId;
//
//@end

@interface UILabel (Touch)

//- (void)setTouchEnable:(BOOL)enable;

- (NSInteger)indexOfAttriTxtAtPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
