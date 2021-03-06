//
//  MHCompleteBeautyView.m


//一键美颜

#import "MHCompleteBeautyView.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"
#import "MHBeautyMenuCell.h"
@interface MHCompleteBeautyView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;
@end

@implementation MHCompleteBeautyView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.lastIndex = 0;
    }
    return self;
}

- (void)cancelQuickBeautyEffect:(MHBeautiesModel *)selectedModel {
    for (int i = 0; i<self.array.count; i++) {
        MHBeautiesModel *model = self.array[i];
        if (i == 0) {
            model.isSelected = YES;
        }
        if ([model.beautyTitle isEqualToString:selectedModel.beautyTitle]) {
            model.isSelected = NO;
        }
    }
    [self.collectionView reloadData];
    self.lastIndex = 0;
}

#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHQuickBeautyCell" forIndexPath:indexPath];
    cell.menuModel = self.array[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((window_width-20) /MHFilterItemColumn, MHFilterCellHeight);
}

#pragma mark - delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *model = self.array[indexPath.row];
    model.isSelected = !model.isSelected;
    
    
    if ([self.delegate respondsToSelector:@selector(handleCompleteEffect:)]) {
        [self.delegate handleCompleteEffect:model];
    }
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = !lastModel.isSelected;
    }
    
    if (indexPath.row == 0) {
       [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"hasSelectedQuickBeauty"];
    } else {
         [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"hasSelectedQuickBeauty"];
    }
    [self.collectionView reloadData];
    self.lastIndex = indexPath.row;
}

#pragma mark - lazy
-(NSMutableArray *)array {
    if (!_array) {

        NSMutableArray * selectedItemArray = [MHSDK shareInstance].completeBeautyArray;
        NSMutableArray * selectedItems = [NSMutableArray array];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MHQuickBeautyParams" ofType:@"plist"];
        NSArray *contentArr = [NSArray arrayWithContentsOfFile:path];
        NSArray *dataArr = contentArr.firstObject;
        
        for (int i = 0; i < selectedItemArray.count; i ++) {
            NSDictionary * selectedItemDic = selectedItemArray[i];
            NSString * selectedName = selectedItemDic[@"name"];
            for (int j = 0; j < dataArr.count; j++) {
                NSDictionary * itemDic = dataArr[j];
                NSString * itemName = itemDic[@"title"];
                if ([selectedName isEqual:itemName]) {
                    [selectedItems addObject:itemDic];
                }
            }
        }
        
        
        _array = [NSMutableArray array];
        for (int i = 0; i<selectedItems.count; i++) {
            NSDictionary *dic = selectedItems[i];
            MHBeautiesModel *model = [MHBeautiesModel mh_quickBeautyModelWithDictionary:dic];
            model.imgName = dic[@"imageName"];
            model.isSelected = i == 0 ? YES : NO;
            model.type = [dic[@"type"] integerValue];
            model.menuType = MHBeautyMenuType_QuickBeauty;
            [_array addObject:model];
        }
    }
    return _array;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 15;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width,self.frame.size.height) collectionViewLayout:layout];
        ///修改MHUI
        _collectionView.backgroundColor = [UIColor clearColor];;;;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHQuickBeautyCell"];
    }
    return _collectionView;
}


@end

