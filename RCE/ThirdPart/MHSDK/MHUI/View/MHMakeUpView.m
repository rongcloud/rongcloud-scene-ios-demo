//
//  MHMakeUpView.m
//  TXLiteAVDemo_UGC
//
//  Created by Apple on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "MHMakeUpView.h"
#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"
#import "WNSegmentControl.h"

static NSString *OriginalImg = @"beautyOrigin";
static NSString *EyelashImg = @"makeupEyelash";
static NSString *LipstickImg = @"makeupLipstick";
static NSString *BlushImg = @"makeupBlush";
static NSString *EyelinerImg = @"makeupEyeLiner";
@interface MHMakeUpView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, assign) NSInteger beautyType;
@property (nonatomic, strong) NSMutableArray *arr;

@property (nonatomic, strong) WNSegmentControl *segmentControl;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation MHMakeUpView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.segmentControl];
        [self addSubview:self.lineView];
        [self addSubview:self.collectionView];
        self.backgroundColor = [UIColor clearColor];
        self.lastIndex = -1;
    }
    return self;
}

- (void)clearAllBeautyEffects {
    for (int i = 0; i<self.array.count; i++) {
        NSString *beautKey = [NSString stringWithFormat:@"beauty_%ld",(long)i];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:beautKey];
    }
}


#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHBeautyMenuCell" forIndexPath:indexPath];
    cell.menuModel = self.array[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((window_width-40)/5, MHMeiyanMenusCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        for (MHBeautiesModel * model in self.array) {
            model.isSelected = NO;
        }
    }else{
        MHBeautiesModel *Model = self.array[0];
        Model.isSelected = NO;
    }
    MHBeautiesModel *currentModel = self.array[indexPath.row];
    currentModel.isSelected = !currentModel.isSelected;
    
    self.lastIndex = indexPath.row;
    [self.collectionView reloadData];
    self.beautyType = currentModel.type;
    
    if ([self.delegate respondsToSelector:@selector(handleMakeUpType:withON:)]) {
        [self.delegate handleMakeUpType:currentModel.type withON:currentModel.isSelected];
    }
}

#pragma mark - lazy
- (NSMutableArray *)array {
    if (!_array) {
        
        NSMutableArray * selectedItemArray = [MHSDK shareInstance].makeupArray;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MHMakeupParams" ofType:@"plist"];
        NSArray *items = [NSArray arrayWithContentsOfFile:path];
        
        
        NSMutableArray * selectedItems = [NSMutableArray array];
        for (int i = 0; i < selectedItemArray.count; i ++) {
            NSDictionary * selectedItemDic = selectedItemArray[i];
            NSString * selectedName = selectedItemDic[@"name"];
            for (int j = 0; j < items.count; j++) {
                NSDictionary * itemDic = items[j];
                NSString * itemName = itemDic[@"name"];
                if ([selectedName isEqual:itemName]) {
                    [selectedItems addObject:itemDic];
                }
            }
        }
        
        _array = [NSMutableArray array];
        for (int i = 0; i<selectedItems.count; i++) {
            NSDictionary * itemDic = selectedItems[i];
            MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
            model.imgName = itemDic[@"imageName"];
            model.beautyTitle = itemDic[@"name"];
            model.menuType = MHBeautyMenuType_MakeUp;
            model.type = [itemDic[@"type"] integerValue];
            NSString *makeUpKey = [NSString stringWithFormat:@"makeUp_%ld",model.type];
            NSString * isSelected = [[NSUserDefaults standardUserDefaults] objectForKey:makeUpKey];
           
            if (isSelected.integerValue == 1) {
                model.isSelected = YES;
            }
            
            [_array addObject:model];
        }
    }
    return _array;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        ///修改MHUI
        CGFloat bottom = _lineView.frame.origin.y + _lineView.frame.size.height;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, bottom, window_width, self.frame.size.height - bottom - MHBottomViewHeight) collectionViewLayout:layout];
        ///修改MHUI
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}
///修改MHUI
- (WNSegmentControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[WNSegmentControl alloc] initWithTitles:@[@"美妆"]];
        _segmentControl.frame = CGRectMake(0, 0, window_width, MHStickerSectionHeight);
        _segmentControl.backgroundColor = [UIColor clearColor];
        [_segmentControl setTextAttributes:@{NSFontAttributeName: Font_12, NSForegroundColorAttributeName: FontColorNormal}
                                  forState:UIControlStateNormal];
        [_segmentControl setTextAttributes:@{NSFontAttributeName: Font_12, NSForegroundColorAttributeName: FontColorSelected}
                                  forState:UIControlStateSelected];
        _segmentControl.selectedSegmentIndex = 0;
        _segmentControl.widthStyle = WNSegmentedControlWidthStyleFixed;
//        [_segmentControl addTarget:self action:@selector(switchList:) forControlEvents:UIControlEventValueChanged];
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

- (NSInteger)currentIndex{
    return _lastIndex;
}

@end
