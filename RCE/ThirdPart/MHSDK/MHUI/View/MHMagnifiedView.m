//
//  MHMagnifiedView.m

//哈哈镜

#import "MHMagnifiedView.h"
#import "MHMagnifiedEffectCell.h"
#import "MHBeautiesModel.h"
#import "MHBeautyParams.h"
#import "WNSegmentControl.h"

@interface MHMagnifiedView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, strong) WNSegmentControl *segmentControl;
@property (nonatomic, strong) UIView *lineView;

@end
@implementation MHMagnifiedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        ///修改MHUI
        [self addSubview:self.segmentControl];
        [self addSubview:self.lineView];
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setIsHiddenHead:(BOOL)isHiddenHead{
    _isHiddenHead = isHiddenHead;
    _segmentControl.hidden = _isHiddenHead;
    if (_isHiddenHead) {
        [_lineView removeFromSuperview];
        self.collectionView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHMagnifiedEffectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHMagnifiedEffectCell" forIndexPath:indexPath];
    cell.model = self.array[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ///修改MHUI
    return CGSizeMake((window_width-20)/4.5, 100);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *model = self.array[indexPath.row];
    model.isSelected = !model.isSelected;
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = !lastModel.isSelected;
    }
    [self.collectionView reloadData];
    self.lastIndex = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(handleMagnify:withIsMenu:)]) {
        [self.delegate handleMagnify:model.type withIsMenu:!_isHiddenHead];
    }
}

#pragma mark - lazy
-(NSMutableArray *)array {
    if (!_array) {
//        NSArray *arr = @[@"无", @"外星人", @"梨梨脸", @"瘦瘦脸", @"镜像脸", @"片段脸", @"水面倒影", @"螺旋镜面", @"鱼眼相机",@"左右镜像"];
//        NSArray *imgs = @[@"haha_cancel",@"waixingren",@"lilian",@"shoushou",@"shangxia",@"pianduanlian",@"daoying",@"luoxuan",@"yuyan",@"zuoyou"];
        
        NSMutableArray * selectedItemArray = [NSMutableArray array];
        if (_isHiddenHead) {
            selectedItemArray = [MHSDK shareInstance].magnifiedArray;
        }else{
            selectedItemArray = [MHSDK shareInstance].meunMagnifiedArray;
        }
       
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MHMagnifiedEffectParams" ofType:@"plist"];
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
            model.isSelected = i == 0 ? YES : NO;
            model.type = [itemDic[@"type"] integerValue];
            model.menuType = MHBeautyMenuType_Magnify;
            
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
        [_collectionView registerClass:[MHMagnifiedEffectCell class] forCellWithReuseIdentifier:@"MHMagnifiedEffectCell"];
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}
///修改MHUI
- (WNSegmentControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[WNSegmentControl alloc] initWithTitles:@[@"哈哈镜"]];
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

@end
