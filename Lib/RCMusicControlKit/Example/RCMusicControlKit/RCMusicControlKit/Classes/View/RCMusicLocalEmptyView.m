//
//  RCMusicLocalEmptyView.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/22.
//

#import "RCMusicLocalEmptyView.h"
#import <Masonry/Masonry.h>

@interface RCMusicLocalEmptyView ()
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIButton *addButton;
@end

@implementation RCMusicLocalEmptyView

- (instancetype)init {
    if (self = [super init]) {
        [self buildLayout];
    }
    return self;
}

- (void)addMusic:(UIButton *)button {
    if (self.addMusicAction) {
        self.addMusicAction();
    }
}

- (void)buildLayout {
    
    [self addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(-40);
        make.size.mas_equalTo(CGSizeMake(120, 40));
    }];
    
    [self addSubview:self.tipsLabel];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.addButton.mas_top).offset(-10);
        make.centerX.equalTo(self);
        make.height.mas_equalTo(20);
    }];
}

- (UILabel *)tipsLabel {
    if (_tipsLabel == nil) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _tipsLabel.font = [UIFont systemFontOfSize:13];
        _tipsLabel.text = @"暂无歌曲，快去添加吧~";
    }
    return _tipsLabel;
}

- (UIButton *)addButton {
    if (_addButton == nil) {
        _addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _addButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _addButton.titleLabel.textColor = [UIColor whiteColor];
        _addButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _addButton.layer.borderWidth = 1;
        _addButton.layer.masksToBounds = YES;
        _addButton.layer.cornerRadius = 20;
        [_addButton setTitle:@"添加歌曲" forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addMusic:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addButton;
}

@end
