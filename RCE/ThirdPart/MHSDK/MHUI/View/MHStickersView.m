//
//  MHStickersView.m


#import "MHStickersView.h"
#import "MHStickerCell.h"
#import "StickerManager.h"
#import "StickerDataListModel.h"
#import "MHSectionStickersView.h"
#import "MHBeautyParams.h"
#import <MHBeautySDK/MHBeautySDK.h>

#define kNetWorkPrefix @"https://data.facegl.com"

#define kBasicMasksUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL21hc2svaW5kZXg="
#define kHighStickersUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL1N0aWNrZXIvaGlnaA=="
#define kHighMasksUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL21hc2svaGlnaA=="
#define kBasicStickersUrl @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBwYXBpL1N0aWNrZXIvaW5kZXg="

@interface MHStickersView () <UIScrollViewDelegate, MHSectionStickersViewDelegate>

@property (nonatomic, strong) NSMutableArray *array;

@property (nonatomic, assign) NSInteger lastIndex;//记录按钮的索引，以便更新UI
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *views;

@property (nonatomic, assign) NSInteger lastViewIndex;//记录View索引，取消选中贴纸
@property (nonatomic, assign) BOOL isFirstSelect;
@property (nonatomic, assign) NSInteger currentViewIndex;
@property (nonatomic, strong) NSMutableArray *titleBtnArr;
@property (nonatomic, strong) NSMutableArray *allArr;
@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, assign) int sdkLevelTYpe;///<sdk类型

@end

@implementation MHStickersView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        ///修改MHUI
        self.backgroundColor = [UIColor clearColor];
        self.lastViewIndex = -1;
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"selectedStickerIndex"];
        _urls = [NSMutableArray array];
        [self configureStickerTypes];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self switchViewToRequestData:0];
        });
    }
    return self;
}

- (void)configureStickerTypes {
    for (UIView *subview in self.subviews) [subview removeFromSuperview];
    ///修改MHUI
    NSAttributedString *basicMask = [self stringAttachment:YZMsg(@"基础面具") textColor:FontColorBlackNormal];
    NSAttributedString *basicSticker = [self stringAttachment:YZMsg(@"基础贴纸") textColor:FontColorSelected];
    NSAttributedString *highMask = [self stringAttachment:YZMsg(@"高级面具") textColor:FontColorBlackNormal];
    NSAttributedString *highSticker = [self stringAttachment:YZMsg(@"高级贴纸") textColor:FontColorBlackNormal];
    NSMutableArray *titleBtns = [NSMutableArray array];
    [self.urls removeAllObjects];
    NSArray * itemNameArray = @[
        @{@"基础贴纸":basicSticker,@"url":kBasicStickersUrl,@"type":@"2"},
        @{@"基础面具":basicMask,@"url":kBasicMasksUrl,@"type":@"3"},
        @{@"高级贴纸":highSticker,@"url":kHighStickersUrl,@"type":@"4"},
        @{@"高级面具":highMask,@"url":kHighMasksUrl,@"type":@"5"}
    ];
    
    NSMutableArray * selectedItem = [MHSDK shareInstance].stickerArray;
    _array = [NSMutableArray array];
    for (int i = 0; i < selectedItem.count; i++) {
        NSDictionary * itemDic1 = selectedItem[i];
        NSString * selectedItemName = itemDic1[@"name"];
        for (int j = 0; j< itemNameArray.count; j++) {
            NSDictionary * itemDic = itemNameArray[j];
            NSAttributedString * name = itemDic[selectedItemName];
            if (name) {
                [titleBtns addObject:name];
                NSString * urlString = [NSString stringWithFormat:@"%@%@",kNetWorkPrefix,itemDic1[@"mark"]];
                NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
                 urlString = [data base64EncodedStringWithOptions:0];
              
                [_urls addObject:urlString];
                [_array addObject:itemDic];
            }
            
        }
    }
    
    self.allArr = [NSMutableArray arrayWithCapacity:titleBtns.count];
    self.titleBtnArr = [NSMutableArray arrayWithCapacity:titleBtns.count];
    self.views = [NSMutableArray arrayWithCapacity:titleBtns.count];
    for (int i = 0; i<titleBtns.count; i++) {
        UIButton *titleBtn = [UIButton buttonWithType:0];
        [titleBtn setAttributedTitle:titleBtns[i] forState:0];
        titleBtn.frame = CGRectMake((window_width/titleBtns.count)*i, 0, window_width/titleBtns.count, MHStickerSectionHeight);
        titleBtn.tag = 1109+i;
        [titleBtn addTarget:self action:@selector(switchStickerOrMask:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:titleBtn];
        NSMutableArray *muArr = [NSMutableArray array];
        [self.allArr addObject:muArr];
        [self.titleBtnArr addObject:titleBtn];
        MHSectionStickersView *stickersView = [[MHSectionStickersView alloc] initWithFrame:CGRectMake(window_width * i, 0, window_width, self.frame.size.height - MHStickerSectionHeight-0.5)];
        stickersView.tag = [_array[i][@"type"] integerValue] + 1111;
        stickersView.lastTag = stickersView.tag;
        stickersView.delegate = self;
        [self.scrollView addSubview:stickersView];
        [self.views addObject:stickersView];
    }
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, MHStickerSectionHeight, window_width, 0.5)];
    _lineView.backgroundColor = LineColor;
    [self addSubview:_lineView];
    [self addSubview:self.scrollView];
    ///修改MHUI
    CGFloat bottom = self.lineView.frame.origin.y + self.lineView.frame.size.height;
    CGRect rect = self.scrollView.frame;
    self.scrollView.frame = CGRectMake(rect.origin.x, bottom, rect.size.width, rect.size.height);
    self.scrollView.contentSize = CGSizeMake(window_width * titleBtns.count, self.frame.size.height - bottom);
}

- (void)switchStickerOrMask:(UIButton *)btn {
    NSInteger tag = btn.tag - 1109;
    [self.scrollView setContentOffset:CGPointMake(window_width * tag, 0) animated:YES];
    [self switchViewToRequestData:tag];
}

- (void)switchSelectedBtnUI:(NSInteger)index textColor:(UIColor *)color {
    UIButton *curentBtn = self.titleBtnArr[index];
    NSAttributedString *str = curentBtn.currentAttributedTitle;
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithAttributedString:str];
    [str2 addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, str.length)];
    [curentBtn setAttributedTitle:str2 forState:0];
}

- (void)clearStikerUI{
    if (self.lastIndex < 0) return;
    if ([MHSDK shareInstance].stickerArray.count == 0) return;
    
    NSString *la = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStickerIndex"];
    if (la == nil || [la isEqualToString:@""]) return;
    
    NSMutableArray *currentArr = self.allArr[self.currentViewIndex];
    NSInteger laindex = la.integerValue;
    if (laindex >= currentArr.count) return;
    
    StickerDataListModel *model = currentArr[laindex];
    model.isSelected = NO;
    
    MHSectionStickersView *currentSubView = self.views[self.currentViewIndex];
    currentSubView.lastIndex = -1;
    [currentSubView.collectionView reloadData];
}

#pragma mark - delegate
- (void)handleSelectedStickerEffect:(NSString *)stickerContent stickerModel:(nonnull StickerDataListModel *)model{
    //NSLog(@"sss---%@",stickerContent);
    if (!IsStringWithAnyText(model.name) && !IsStringWithAnyText(model.resource) ) {
        if ([self.delegate respondsToSelector:@selector(handleStickerEffect:withLevel:)]) {
            [self.delegate handleStickerEffect:@"" withLevel:0];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(handleStickerEffect:withLevel:)]) {
            NSDictionary * itemDic = self.array[self.currentViewIndex];
            NSInteger level = [itemDic[@"type"] integerValue];
            [self.delegate handleStickerEffect:stickerContent withLevel:level];
        }
    }
}

//当切换分类后，点击贴纸，取消上一个分类下贴纸的选中效果
- (void)reloadLastStickerSelectedStatus:(BOOL)needReset {
    if (!self.isFirstSelect) {
        self.lastViewIndex = 0;
        self.isFirstSelect = YES;
    }
    MHSectionStickersView *lastSubView = self.views[self.lastViewIndex];

    NSMutableArray *lastArr = self.allArr[self.lastViewIndex];
    NSString *la = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStickerIndex"];
    if (la != nil && ![la isEqualToString:@""]) {
        NSInteger laindex = la.integerValue;
        if (laindex < lastArr.count) {
            StickerDataListModel *model = lastArr[laindex];
            model.isSelected = !needReset;
            [lastSubView.collectionView reloadData];
        }
    }
    MHSectionStickersView *subView = self.views[self.currentViewIndex];
    subView.lastTag = subView.tag;
    self.lastViewIndex = self.currentViewIndex;
}

#pragma mark - data

- (void)switchViewToRequestData:(NSInteger)index {
    if (index < 0 || index >= self.allArr.count) return;
    NSMutableArray *arr = self.allArr[index];
    MHSectionStickersView *currentSubView = self.views[index];
    NSString *url = self.urls[index];
    if (arr.count > 0) {
        [currentSubView configureData:arr];
    } else {
        [[StickerManager sharedManager] requestStickersListWithUrl:url
                                                           Success:^(NSArray<StickerDataListModel *> * _Nonnull stickerArray) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [arr addObjectsFromArray:stickerArray];
                                                                   [currentSubView configureData:arr];
                                                               });
                                                           } Failed:^{}];
    }
    
    if (!self.isFirstSelect) {
        self.lastViewIndex = 0;
        self.isFirstSelect = YES;
        self.lastIndex = 0;
    }
    
    MHSectionStickersView *lastSubView = self.views[self.lastViewIndex];
    currentSubView.lastTag = lastSubView.tag;
    
    [self switchSelectedBtnUI:index textColor:FontColorSelected];
    if (self.lastIndex != index) {
        [self switchSelectedBtnUI:self.lastIndex textColor:FontColorBlackNormal];
    }
    self.lastIndex = index;
    self.currentViewIndex = index;
}

#pragma mark - scrollDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / window_width;
    [self switchViewToRequestData:index];
}

#pragma mark - lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height - MHStickerSectionHeight-0.5)];
        _scrollView.pagingEnabled = YES;
        ///修改MHUI
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (NSAttributedString *)stringAttachment:(NSString *)content textColor:(UIColor *)color {
    NSDictionary<NSAttributedStringKey, id> *attrs = @{
        NSForegroundColorAttributeName: color,
        NSFontAttributeName: Font_12,
    };
    return [[NSAttributedString alloc] initWithString:content attributes:attrs];
}

- (int)sdkLevelTYpe{
    return [[MHSDK shareInstance] getSDKLevel];
}

@end
