//
//  RCMusicCategorySelector.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import "RCMusicCategorySelector.h"
#import "RCMusicCategoryData.h"
#import <Masonry/Masonry.h>
#import "RCMusicCategorySelectorAppearance.h"
#import "RCMusicSheetResponse.h"
#import "UIColor+RCMHex.h"

#pragma mark ---------RCMusicCategoryCell
@interface RCMusicCategoryCell : UICollectionViewCell
@property (class, nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong) id <RCMusicCategoryInfo> item;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) RCMusicCategorySelectorAppearance *appearance;
@property (nonatomic, strong) UIView *indicatorView;
@end

@implementation RCMusicCategoryCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout {
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
    }];
    
    [self addSubview:self.indicatorView];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.titleLabel);
        make.size.mas_equalTo(self.appearance.indicatorSize);
        make.bottom.equalTo(self);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
    }];
}

- (void)setItem:(id<RCMusicCategoryInfo>)item {
    _item = item;
    if (item.selected) {
        self.titleLabel.font = self.appearance.selectedFont;
        self.titleLabel.text = item.categoryName;
        self.titleLabel.textColor = self.appearance.selectedTextColor;
        self.indicatorView.hidden = NO;
    } else {
        self.titleLabel.font = self.appearance.normalFont;
        self.titleLabel.text = item.categoryName;
        self.titleLabel.textColor = self.appearance.normalTextColor;
        self.indicatorView.hidden = YES;
    }
}

+ (NSString *)identifier {
    return @"RCMusicCategoryCellIdentifier";
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = self.appearance.normalTextColor;
        _titleLabel.font = self.appearance.normalFont;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIView alloc] init];
        _indicatorView.hidden = YES;
        _indicatorView.backgroundColor = self.appearance.selectedTextColor;
        _indicatorView.hidden = !self.appearance.showIndicator;
    }
    return _indicatorView;
}

- (RCMusicCategorySelectorAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicCategorySelectorAppearance alloc] init];
    }
    return _appearance;
}
@end

#pragma mark ---------RCMusicCategorySelector

@interface RCMusicCategorySelector ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *categoryView;
@property (nonatomic, strong) id<RCMusicCategoryInfo> selectedItem;
@property (nonatomic, strong) RCMusicCategorySelectorAppearance *appearance;
@end

@implementation RCMusicCategorySelector
- (instancetype)init {
    if (self = [super init]) {
//        self.backgroundColor = self.appearance.backgroundColor;
        self.userInteractionEnabled = YES;
        [self buildLayout];
    }
    return self;
}

- (void)setItems:(NSArray<RCMusicCategoryInfo> *)items {
    _items = items;
    if (items != nil) {
        if (self.selectedItem == nil && items.count > 0) {
            self.selectedItem = items.firstObject;
        }
        [self.categoryView reloadData];
    } else {
        NSLog(@"NSArray<RCMusicCategoryData *> items is nil");
    }
}

#pragma mark - COLLECTION VIEW DELEGATE

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMusicCategoryCell *cell = (RCMusicCategoryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:RCMusicCategoryCell.identifier forIndexPath:indexPath];
    id<RCMusicCategoryInfo> item = self.items[indexPath.row];
    item.selected = item == self.selectedItem;
    cell.item = item;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<RCMusicCategoryInfo> item = self.items[indexPath.row];
    self.selectedItem = item;
    [collectionView reloadData];
    if ([self.delegate respondsToSelector:@selector(categoryDidSelectItemAtIndex:)]) {
        [self.delegate categoryDidSelectItemAtIndex:indexPath.row];
    }
}

#pragma mark -LAYOUT SUBVIEWS

- (void)buildLayout {
    [self addSubview:self.categoryView];
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.bottom.equalTo(self).offset(-10);
        make.leading.equalTo(self).offset(10);
        make.trailing.equalTo(self).offset(-10);
    }];
}

#pragma mark -GETTER

- (UICollectionView *)categoryView {
    if (_categoryView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 10;
        layout.estimatedItemSize = CGSizeMake(60, 30);
        _categoryView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _categoryView.delegate = self;
        _categoryView.dataSource = self;
        _categoryView.showsHorizontalScrollIndicator = NO;
        _categoryView.backgroundColor = [UIColor clearColor];
        [_categoryView registerClass:[RCMusicCategoryCell class] forCellWithReuseIdentifier:RCMusicCategoryCell.identifier];
    }
    return _categoryView;
}

-(RCMusicCategorySelectorAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicCategorySelectorAppearance alloc] init];
    }
    return _appearance;
}
@end
