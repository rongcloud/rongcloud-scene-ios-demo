//
//  RCMusicRemoteEmptyView.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/22.
//

#import "RCMusicRemoteEmptyView.h"
#import <Masonry/Masonry.h>
#import "UIImage+RCMBundle.h"

@interface RCMusicRemoteEmptyView ()
@property (nonatomic, strong) UIImageView *emptyImageView;
@property (nonatomic, strong) UILabel *tipsLabel;
@end

@implementation RCMusicRemoteEmptyView

- (instancetype)init {
    if (self = [super init]) {
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout {
    [self addSubview:self.emptyImageView];
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(90, 90));
    }];
    
    [self addSubview:self.tipsLabel];
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.emptyImageView);
        make.top.equalTo(self.emptyImageView.mas_bottom).offset(20);
    }];
}

- (UIImageView *)emptyImageView {
    if (_emptyImageView == nil) {
        _emptyImageView = [[UIImageView alloc] init];
        _emptyImageView.image = [UIImage rcm_imageNamed:@"remote_empty_icon"];
    }
    return _emptyImageView;
}

- (UILabel *)tipsLabel {
    if (_tipsLabel == nil) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.font = [UIFont systemFontOfSize:13];
        _tipsLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        _tipsLabel.text = @"暂未发现您收藏的歌曲";
    }
    return _tipsLabel;
}
@end
