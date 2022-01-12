//
//  RCAttribute+Convert.m
//  RCChatroomSceneKit
//
//  Created by johankoi on 2021/12/9.
//

#import "RCAttribute+Convert.h"

@implementation RCCorner (Convert)
- (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect {
    UIRectCorner corner = 0;
    CGFloat radii = 0;
    if (self.leftTop != 0) {
        corner |= UIRectCornerTopLeft;
        radii = self.leftTop;
    }
    if (self.rightTop != 0) {
        corner |= UIRectCornerTopRight;
        radii = self.rightTop;
    }
    if (self.leftBottom != 0) {
        corner |= UIRectCornerBottomLeft;
        radii = self.leftBottom;
    }
    if (self.rightBottom != 0) {
        corner |= UIRectCornerBottomRight;
        radii = self.rightBottom;
    }
    if (self.radius != 0 && corner == 0) {
        corner |= UIRectCornerAllCorners;
        radii = self.radius;
    }
    UIBezierPath *cornerPath = nil;
    if (radii != 0 && corner != 0) {
        cornerPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:CGSizeMake(radii, radii)];
    }
    return cornerPath;
}
@end


@implementation RCInsets (Convert)
- (UIEdgeInsets)toUIEdgeInsets {
    return UIEdgeInsetsMake(self.top, self.left, self.bottom, self.right);
}
@end


@implementation RCColor (Convert)
- (UIColor *)toUIColor {
    CGFloat r = self.red   / 255.0;
    CGFloat g = self.green / 255.0;
    CGFloat b = self.blue  / 255.0;
    CGFloat a = self.alpha;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
@end


@implementation RCSize (Convert)
- (CGSize)toCGSize {
    return CGSizeMake(self.width, self.height);
}
@end




@implementation RCAttribute (Convert)

@end
