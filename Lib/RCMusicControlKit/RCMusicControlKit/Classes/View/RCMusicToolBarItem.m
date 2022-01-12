//
//  RCMusicToolBarItem.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/15.
//

#import "RCMusicToolBarItem.h"
#import "RCMusicBarItemAppearance.h"
#import "UIImage+RCMBundle.h"
#import <Masonry/Masonry.h>
#import "UIButton+WebCache.h"

@interface UIButton (RCMMutex)
@property (class, nonatomic, strong) NSPointerArray *mutexButtons;
@end

@implementation UIButton (RCMMutex)

static NSPointerArray *k_btns;

+ (NSPointerArray *)mutexButtons {
    if (k_btns == nil) {
        k_btns = [NSPointerArray weakObjectsPointerArray];
    }
    return k_btns;
}

+ (void)setMutexButtons:(NSPointerArray *)mutexButtons {}

- (void)record {
    [UIButton.mutexButtons compact];
    [UIButton.mutexButtons addPointer:(__bridge void*)self];
}

- (void)resetRecordButtonSelectedState {
    [UIButton.mutexButtons compact];
    for (UIButton *btn in UIButton.mutexButtons) {
        btn.selected = NO;
    }
}

@end

@interface RCMusicToolBarItem ()
@property (nonatomic, strong) RCMusicBarItemAppearance *appearance;
@property (nonatomic, copy) NSString *normalImage;
@property (nonatomic, copy) NSString *selectedImage;
@property (nonatomic, strong) UIButton *contentButton;
@property (nonatomic, weak) id<NSObject> target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign, readwrite, getter=isRecord) BOOL record;
@end

@implementation RCMusicToolBarItem

- (void)dealloc {
    
}

- (instancetype)initWithNormalImage:(nullable NSString *)normalImage
                      selectedImage:(nullable NSString *)selectedImage
                             record:(BOOL)record
                             target:(nullable id)target
                             action:(nullable SEL)action {
    if (self = [self initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)]) {
        self.target = target;
        self.action = action;
        self.selectedImage = selectedImage;
        self.normalImage = normalImage;
        self.record = record;
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout {
    self.backgroundColor = self.appearance.backgroundColor;
    [self addSubview:self.contentButton];
    [self.contentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.appearance.size);
        make.centerY.equalTo(self).offset(self.appearance.contentInset.top + self.appearance.contentInset.bottom);
        make.centerX.equalTo(self).offset(self.appearance.contentInset.left + self.appearance.contentInset.right);
    }];
}

#pragma mark - ACTION

- (void)buttonClick:(UIButton *)button {
    if (self.isRecord) {
        [button resetRecordButtonSelectedState];
    }
    button.selected = !button.selected;
    if ([self.target respondsToSelector:self.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action];
#pragma clang diagnostic pop
    }
}

#pragma mark -GETTER

- (RCMusicBarItemAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicBarItemAppearance alloc] init];
    }
    return _appearance;
}

- (UIButton *)contentButton {
    if (_contentButton == nil) {
        _contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _contentButton.backgroundColor = self.appearance.backgroundColor;
        [self buttonSetBgImage:_contentButton image:self.normalImage state:UIControlStateNormal];
        [self buttonSetBgImage:_contentButton image:self.selectedImage state:UIControlStateSelected];
        [_contentButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        _contentButton.layer.masksToBounds = YES;
        _contentButton.layer.cornerRadius = self.appearance.size.width/2;
        if (_record) {
            [_contentButton record];
        }
    }
    return _contentButton;
}

- (void)buttonSetBgImage:(UIButton *)button image:(NSString *)imageString state:(UIControlState)state {
    if ([imageString hasPrefix:@"http"]) {
        [button sd_setBackgroundImageWithURL:[NSURL URLWithString:imageString] forState:state];
    } else {
        [button setBackgroundImage:[UIImage rcm_imageNamed:imageString] forState:state];
    }
}

- (CGSize)size {
    return self.appearance.size;
}

- (BOOL)isSelected {
    return self.contentButton.selected;
}

#pragma  mark -SETTER

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.appearance.size = frame.size;
}

- (void)setSelected:(BOOL)selected {
    [self.contentButton resetRecordButtonSelectedState];
    self.contentButton.selected = YES;
}
@end
