//
//  MHSpecificAssembleView.m

//特效合集

#import "MHSpecificAssembleView.h"
#import "MHBeautyParams.h"
#import "MHPrintView.h"
#import "MHSpecificEffectView.h"
#import "WNSegmentControl.h"
#import "MHBeautiesModel.h"
#import "MHMagnifiedView.h"

#import "MHActionView.h"
#import <MHBeautySDK/MHSDK.h>
@interface MHSpecificAssembleView ()<MHSpecificEffectViewDelegate,MHPrintViewDelegate,MHActionViewDelegate,MHMagnifiedViewDelegate>
@property (nonatomic, strong) MHSpecificEffectView *specificView;//特效
@property (nonatomic, strong) MHPrintView *printView;//水印
@property (nonatomic, strong) MHMagnifiedView *magnifiedView;//哈哈镜
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) NSMutableArray * viewsArray;
@property (nonatomic, strong) UIView *lastView;
@property (nonatomic, strong) WNSegmentControl *segmentControl;
///修改MHUI
@property (nonatomic, strong) MHActionView * stickerView;//动作
@property (nonatomic, assign) int sdkLevelTYpe;///<sdk类型

@end

@implementation MHSpecificAssembleView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1;
        [self addSubview:self.segmentControl];
        [self addSubview:self.lineView];
        
        ///修改MHUI
        [self addSubview:self.viewsArray[0]];
        
    }
    return self;
}
- (void)getActionSource{
    [self.stickerView getSticks];
}
- (void)clearAllActionEffects{
    [self.stickerView clearAllActionEffects];
}

#pragma mark - Action
- (void)switchList:(WNSegmentControl *)segmentControl {
    UIView *currentView = self.viewsArray[segmentControl.selectedSegmentIndex];
    if (![currentView isEqual:self.lastView]) {
        [self.lastView removeFromSuperview];
    }
    [self addSubview:currentView];
    self.lastView = currentView;
}

#pragma mark - delegate
//水印
- (void)handlePrint:(MHBeautiesModel *)model {
    if ([self.delegate respondsToSelector:@selector(handleWatermarkWithModel:)]) {
        [self.delegate handleWatermarkWithModel:model];
    }
    
}

//特效
- (void)handleSpecific:(NSInteger)type {
    if ([self.delegate respondsToSelector:@selector(handleSpecificWithType:)]) {
        [self.delegate handleSpecificWithType:type];
    }
}

//哈哈镜

- (void)handleMagnify:(NSInteger)type withIsMenu:(BOOL)isMenu{
    if ([self.delegate respondsToSelector:@selector(handleMagnityWithType:)]) {
        [self.delegate handleMagnityWithType:type];
    }
}


#pragma mark - delegate
- (void)handleStickerActionEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model action:(int)action{
    NSLog(@"sss---%@",stickerContent);
    
    if (!IsStringWithAnyText(model.name) && !IsStringWithAnyText(model.resource) ) {
        if ([self.delegate respondsToSelector:@selector(handleSpecificStickerActionEffect: sticker:action:)]) {
            [self.delegate handleSpecificStickerActionEffect:@"" sticker:nil action:0];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(handleSpecificStickerActionEffect: sticker:action:)]) {
            [self.delegate handleSpecificStickerActionEffect:stickerContent sticker:model action:action];
        }
    }
    if (action==0) {
        if ([self.delegate respondsToSelector:@selector(handleSpecificStickerActionEffect: sticker:action:)]) {
            [self.delegate handleSpecificStickerActionEffect:@"" sticker:nil action:0];
        }
    }
}

#pragma mark - lazy
- (NSArray *)viewsArray {
    if (!_viewsArray) {
        _viewsArray = [NSMutableArray arrayWithArray: self.sdkLevelTYpe==1?@[self.specificView,self.printView,self.stickerView,self.magnifiedView]:@[self.specificView,self.printView]];
    }
    return _viewsArray;
}

- (MHActionView*)stickerView{
    if (!_stickerView) {
        CGFloat bottom =  _lineView.frame.origin.y + _lineView.frame.size.height;
        _stickerView = [[MHActionView alloc] initWithFrame:CGRectMake(0, bottom, window_width, MHSpecificAssembleViewHeight-bottom - MHBottomViewHeight)];
        _stickerView.delegate = self;
        
    }
    return _stickerView;
}

- (MHSpecificEffectView *)specificView {
    if (!_specificView) {
        ///修改MHUI
        CGFloat bottom =  self.lineView.frame.origin.y + self.lineView.frame.size.height;
        _specificView = [[MHSpecificEffectView alloc] initWithFrame:CGRectMake(0, bottom, window_width, MHSpecificAssembleViewHeight-bottom -  MHBottomViewHeight)];
        _specificView.delegate = self;
    }
    return _specificView;
}

- (MHPrintView *)printView {
    if (!_printView) {
        CGFloat bottom =  _lineView.frame.origin.y + _lineView.frame.size.height;
        _printView = [[MHPrintView alloc] initWithFrame:CGRectMake(0, bottom, window_width, MHSpecificAssembleViewHeight-bottom - MHBottomViewHeight)];
        _printView.delegate = self;
        
    }
    return _printView;
}


- (MHMagnifiedView *)magnifiedView {
    if (!_magnifiedView) {
        CGFloat bottom =  _lineView.frame.origin.y + _lineView.frame.size.height;
        _magnifiedView = [[MHMagnifiedView alloc] initWithFrame:CGRectMake(0, bottom, window_width, MHSpecificAssembleViewHeight-bottom -  MHBottomViewHeight)];
        _magnifiedView.delegate = self;
        _magnifiedView.isHiddenHead = YES;
    }
    return _magnifiedView;
}

- (WNSegmentControl *)segmentControl {
    if (!_segmentControl) {
        
        _viewsArray = [NSMutableArray array];
        NSMutableArray * selectedItem = [MHSDK shareInstance].effectMenuArray;
        
        NSMutableArray * nameArr = [NSMutableArray array];
        for (int i = 0; i < selectedItem.count; i ++) {
            NSDictionary * itemDic = selectedItem[i];
            NSString * itemName = itemDic[@"name"];
            [nameArr addObject:itemName];
        }
//        _segmentControl = [[WNSegmentControl alloc] initWithTitles:self.sdkLevelTYpe == 1?@[@"特效",@"水印",@"动作",@"哈哈镜"]:@[@"特效",@"水印"]];
        _segmentControl = [[WNSegmentControl alloc] initWithTitles:nameArr];
        
        _segmentControl.frame = CGRectMake(0, 0, window_width, MHStickerSectionHeight);
        ///修改MHUI
        _segmentControl.backgroundColor = [UIColor clearColor];
        [_segmentControl setTextAttributes:@{NSFontAttributeName: Font_12, NSForegroundColorAttributeName: FontColorBlackNormal}
                                  forState:UIControlStateNormal];
        [_segmentControl setTextAttributes:@{NSFontAttributeName: Font_12, NSForegroundColorAttributeName: FontColorSelected}
                                  forState:UIControlStateSelected];
        _segmentControl.selectedSegmentIndex = 0;
        _segmentControl.widthStyle = WNSegmentedControlWidthStyleFixed;
        [_segmentControl addTarget:self action:@selector(switchList:) forControlEvents:UIControlEventValueChanged];
        NSArray * items =  @[@{@"特效":self.specificView},@{@"水印":self.printView},@{@"动作":self.stickerView},@{@"哈哈镜":self.magnifiedView}];
        for (int i = 0; i < selectedItem.count; i ++) {
            NSDictionary * itemDic = selectedItem[i];
            NSString * itemName = itemDic[@"name"];
            for (int j = 0; j < items.count; j ++) {
                NSDictionary * itemDic = items[j];
                if ([itemDic.allKeys[0] isEqual:itemName]) {
                    [_viewsArray addObject:itemDic.allValues[0]];
                }
            }
        }
        self.lastView = self.viewsArray[0];
    }
    return _segmentControl;
}
- (UIView *)lineView {
    if (!_lineView) {
        CGFloat bottom = _segmentControl.frame.origin.y + _segmentControl.frame.size.height;
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, bottom, window_width, 0.5)];
        _lineView.backgroundColor = LineColor;
    }
    return _lineView;
}

- (int)sdkLevelTYpe{
    return [[MHSDK shareInstance] getSDKLevel];
}
@end
