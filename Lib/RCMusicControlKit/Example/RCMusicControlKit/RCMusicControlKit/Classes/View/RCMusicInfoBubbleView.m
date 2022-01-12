//
//  RCMusicInfoBubbleView.m
//  RCE
//
//  Created by xuefeng on 2021/11/28.
//

#import "RCMusicInfoBubbleView.h"
#import "UUMarqueeView.h"
#import <Masonry/Masonry.h>
#import "UIImage+RCMBundle.h"
#import "RCMusicEngine.h"
#import "RCMusicDefine.h"
#import "RCMusicInfo.h"
#import "UIImageView+WebCache.h"

@interface RCMusicInfoBubbleView () <UUMarqueeViewDelegate>
@property (nonatomic, strong) UUMarqueeView *marqueeView;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, assign) CGFloat musicNameWidth;
@property (nonatomic, copy) NSString *musicName;
@end

@implementation RCMusicInfoBubbleView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMusicInfo:) name:RCMusicAsyncMixStateNotification object:nil];
        [self buildLayout];
    }
    return self;
}

- (void)updateMusicInfo:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        id<RCMusicInfo> info = (id<RCMusicInfo>)notification.object[@"musicInfo"];
        CGFloat alpha;
        if (info) {
            self.musicName = info.musicName;
            [self.avatarView sd_setImageWithURL:[NSURL URLWithString:info.coverUrl]];
            [self.marqueeView reloadData];
            alpha = 1;
            [self startAnimation];
        } else {
            alpha = 0;
            [self stopAnimation];
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.alpha = alpha;
        }];
    });
}

- (void)startAnimation {
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(M_PI*2.0)];
    rotationAnimation.duration = 4.0;
    rotationAnimation.removedOnCompletion = NO;
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.fillMode = kCAFillModeForwards;
    [self.container.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimation {
    [self.container.layer removeAllAnimations];
}

- (void)buildLayout {
    [self addSubview:self.marqueeView];
    
    [self addSubview:self.container];
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.bottom.equalTo(self);
        make.width.mas_equalTo(self.mas_height).multipliedBy(1);
    }];
    
    [self.container addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.container);
    }];
    
    [self.container addSubview:self.avatarView];
    [self.avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.container);
        make.size.mas_offset(CGSizeMake(38, 38));
    }];
    
    [self.container addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.container);
    }];
    
    self.alpha = 0;
}

- (UUMarqueeView *)marqueeView {
    if (_marqueeView == nil) {
        _marqueeView = [[UUMarqueeView alloc] initWithFrame:CGRectMake(16, 10, 80, 30) direction:UUMarqueeViewDirectionLeftward];
        _marqueeView.delegate = self;
        _marqueeView.timeIntervalPerScroll = 0;
        _marqueeView.timeDurationPerScroll = 2;
        _marqueeView.itemSpacing = 10;
        _marqueeView.useDynamicHeight = YES;
        [self.marqueeView reloadData];
        [self.marqueeView start];
    }
    return _marqueeView;
}

- (UIImageView *)avatarView {
    if (_avatarView == nil) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = 19;
    }
    return _avatarView;
}

- (UIImageView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIImageView alloc] initWithImage:[UIImage rcm_imageNamed:@"music_bubble_small_bg"]];
    }
    return _bgView;
}

- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] initWithImage:[UIImage rcm_imageNamed:@"music_icon"]];
    }
    return _iconView;
}

- (UIView *)container {
    if (_container == nil) {
        _container = [[UIView alloc] init];
    }
    return _container;
}

- (void)setMusicName:(NSString *)musicName {
    _musicName = musicName;
    _musicNameWidth = [musicName sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0f]}].width;
}

- (NSUInteger)numberOfDataForMarqueeView:(UUMarqueeView *)marqueeView {
    return 1;
}

- (void)createItemView:(UIView *)itemView forMarqueeView:(UUMarqueeView *)marqueeView {
    UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
    content.font = [UIFont systemFontOfSize:14.0f];
    content.textColor = [UIColor whiteColor];
    content.text = self.musicName;
    content.textAlignment = NSTextAlignmentCenter;
    content.tag = 1001;
    [itemView addSubview:content];
}

- (void)updateItemView:(UIView*)itemView atIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    UILabel *content = [itemView viewWithTag:1001];
    content.text = self.musicName;
}

- (CGFloat)itemViewWidthAtIndex:(NSUInteger)index forMarqueeView:(UUMarqueeView*)marqueeView {
    return self.musicNameWidth;
}

@end
