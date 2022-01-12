//
//  RCAttribute+Convert.h
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/9.
//

#import "RCAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCCorner (Convert)
- (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect;
@end

@interface RCInsets (Convert)
- (UIEdgeInsets)toUIEdgeInsets;
@end

@interface RCColor (Convert)
- (UIColor *)toUIColor;
@end

@interface RCSize (Convert)
- (CGSize)toCGSize;
@end



@interface RCAttribute (Convert)

@end

NS_ASSUME_NONNULL_END
