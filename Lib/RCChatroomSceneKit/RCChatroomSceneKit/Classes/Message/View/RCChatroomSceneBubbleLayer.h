//
//  RCChatroomSceneBubbleLayer.h
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/27.
//

#import <QuartzCore/QuartzCore.h>
@class RCCorner;
NS_ASSUME_NONNULL_BEGIN

@interface RCChatroomSceneBubbleLayer : CAShapeLayer

- (void)updateWithFrame:(CGRect)frame corner:(RCCorner *)corner;

@end

NS_ASSUME_NONNULL_END
