//
//  RCChatroomSceneBubbleLayer.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/27.
//

#import "RCChatroomSceneBubbleLayer.h"
#import "RCAttribute+Convert.h"

@implementation RCChatroomSceneBubbleLayer

- (void)updateWithFrame:(CGRect)frame corner:(RCCorner *)corner {
    self.frame = frame;
    UIBezierPath *cornerPath = [corner bezierPathWithRoundedRect:self.bounds];
    if (cornerPath) {
        self.path = cornerPath.CGPath;
    }
}

@end
