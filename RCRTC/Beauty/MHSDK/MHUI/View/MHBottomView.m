//
//  MHBottomView.m
//  TXLiteAVDemo_UGC
//
//  Created by Apple on 2021/2/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "MHBottomView.h"
@interface MHBottomView ()
@end
@implementation MHBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self createSubviews];

    }
    return self;
}


#pragma mark - 穿透点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];

        if (hitView == self) {
            return nil; // 此处返回空即不相应任何事件
        }
        return hitView;
}

#pragma mark - 创建子视图
- (void)createSubviews{
}

@end
