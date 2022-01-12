//
//  RCChatroomSceneView.m
//  RCChatroomSceneKit
//
//  Created by shaoshuai on 2021/11/3.
//

#import <Masonry/Masonry.h>

#import "RCChatroomSceneView.h"

#import "RCChatroomSceneToolBar.h"
#import "RCChatroomSceneMessageView.h"

@interface RCChatroomSceneView ()

@property (nonatomic, strong) RCChatroomSceneMessageView *messageView;
@property (nonatomic, strong) RCChatroomSceneToolBar *toolBar;

@end

@implementation RCChatroomSceneView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.messageView];
        [self addSubview:self.toolBar];
        
        [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
            make.height.mas_equalTo(44);
        }];
        
        [self.messageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
            make.bottom.equalTo(self.toolBar.mas_top);
        }];
    }
    return self;
}

- (RCChatroomSceneMessageView *)messageView {
    if (_messageView == nil) {
        _messageView = [[RCChatroomSceneMessageView alloc] init];
    }
    return _messageView;
}

- (RCChatroomSceneToolBar *)toolBar {
    if (_toolBar == nil) {
        _toolBar = [[RCChatroomSceneToolBar alloc] init];
    }
    return _toolBar;
}

@end
