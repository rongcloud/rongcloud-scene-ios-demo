//
//  UILabel+Touch.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/10/28.
//

#import "UILabel+Touch.h"

@implementation UILabel (Touch)

- (NSInteger)indexOfAttriTxtAtPoint:(CGPoint)point {
    if (self.attributedText == nil) return NSNotFound;
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.frame.size];
    textContainer.lineFragmentPadding = 0;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    textContainer.lineBreakMode = self.lineBreakMode;
    
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    
    NSTextStorage *storage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [storage addLayoutManager:layoutManager];
    
    return [layoutManager characterIndexForPoint:point
                                 inTextContainer:textContainer
        fractionOfDistanceBetweenInsertionPoints:nil];
}

@end
