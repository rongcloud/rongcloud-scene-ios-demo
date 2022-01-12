//
//  RCMusicToolBar.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/15.
//

#import "RCMusicToolBar.h"
#import "RCMusicToolBarAppearance.h"
#import "RCMusicColors.h"
#import "Masonry.h"

@interface RCMusicToolBar ()
@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIStackView *leftContainer;
@property (nonatomic, strong) UIStackView *rightContainer;
@property (nonatomic, strong) RCMusicToolBarAppearance *appearance;
@end

@implementation RCMusicToolBar

- (instancetype)initWithItems:(NSArray <__kindof RCMusicToolBarItem*> *)items {
    return [self initWithLeftItems:items rightItems:nil];
}

- (instancetype)initWithLeftItems:(NSArray <__kindof RCMusicToolBarItem*> * _Nullable)leftItems rightItems:(NSArray <__kindof RCMusicToolBarItem*> * _Nullable)rightItems {
    if (self = [super init]) {
        self.leftItems = leftItems;
        self.rightItems = rightItems;
        [self buildLayout];
//        self.backgroundColor = self.appearance.backgroundColor;
    }
    return self;
}

- (void)buildLayout {
    self.backgroundColor = self.appearance.backgroundColor;
    
    [self addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.leftContainer];
    [self.leftContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.leading.equalTo(self).offset(self.appearance.leading);
        make.width.mas_equalTo([self containerWidth:self.leftItems]);
    }];
    
    [self addSubview:self.rightContainer];
    [self.rightContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.trailing.equalTo(self).offset(self.appearance.trailing);
        make.width.mas_equalTo([self containerWidth:self.rightItems]);
    }];
}

- (CGFloat)containerWidth:(NSArray<__kindof RCMusicToolBarItem*> *)items {
    CGFloat width = 0;
    if (items.count == 1) {
        return items.firstObject.size.width;
    }
    if (items != nil && items.count > 0) {
        for (RCMusicToolBarItem *item in items) {
            width += item.size.width;
        }
        width += self.appearance.spacing*(self.leftItems.count);
    }
    return width;
}

#pragma mark -GETTER

- (UIVisualEffectView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    }
    return _backgroundView;;
}

- (UIStackView *)leftContainer {
    if (_leftContainer == nil) {
        if (self.leftItems) {
            _leftContainer = [[UIStackView alloc] initWithArrangedSubviews:self.leftItems];
        } else {
            _leftContainer = [[UIStackView alloc] init];
        }
        _leftContainer.axis = UILayoutConstraintAxisHorizontal;
        _leftContainer.distribution = UIStackViewDistributionFillEqually;
        _leftContainer.spacing = self.appearance.spacing;
    }
    return _leftContainer;
}

- (UIStackView *)rightContainer {
    if (_rightContainer == nil) {
        if (self.rightItems) {
            _rightContainer = [[UIStackView alloc] initWithArrangedSubviews:self.rightItems];
        } else {
            _rightContainer = [[UIStackView alloc] init];
        }
        _rightContainer.axis = UILayoutConstraintAxisHorizontal;
        _rightContainer.distribution = UIStackViewDistributionFillEqually;
        _rightContainer.spacing = self.appearance.spacing;
    }
    return _rightContainer;
}

- (RCMusicToolBarAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicToolBarAppearance alloc] init];
    }
    return _appearance;
}
@end
