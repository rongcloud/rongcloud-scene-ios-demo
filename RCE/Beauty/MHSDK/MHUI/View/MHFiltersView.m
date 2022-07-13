//
//  MHFiltersView.m

//滤镜

#import "MHFiltersView.h"
#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"
#define kFilterName @"kFilterName"
@interface MHFiltersView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;

@end
@implementation MHFiltersView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.lastIndex = 0;
    }
    return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
     MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHFilterCell" forIndexPath:indexPath];
    cell.menuModel = self.array[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width-20) /MHFilterItemColumn, MHFilterCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *model = self.array[indexPath.row];
    model.isSelected = !model.isSelected;
    
    if ([self.delegate respondsToSelector:@selector(handleFiltersEffect: filterName:)]) {
        [self.delegate handleFiltersEffect:model.type filterName:model.imgName];
    }
        
    MHBeautiesModel *lastModel = self.array[self.lastIndex];
    lastModel.isSelected = !lastModel.isSelected;
    
    [self.collectionView reloadData];
    self.lastIndex = indexPath.row;
}

#pragma mark - lazy


-(NSMutableArray *)array {
    if (!_array) {
        //此处的恋爱对应的就是romance
//        NSArray *arr = @[@"filterOrigin",@"langman2",@"qingxin2",@"weimei2",@"fennen2", @"huaijiu2", @"landiao2",@"qingliang2",@"rixi2",@"chengshi",@"chulian",@"chuxin",@"danse",@"fanchase",@"hupo",@"meiwei",@"mitaofen",@"naicha",@"pailide",@"wutuobang",@"xiyou",@"rizha",@"blackcat",@"blackwhite",@"brooklyn",@"calm",@"cool",@"kevin",@"romance"];
//        NSArray *filtersArr = @[@"原图",@"浪漫",@"清新",@"唯美",@"粉嫩",@"怀旧",@"蓝调",@"清凉",@"日系",@"城市",@"初恋",@"初心",@"单色",@"反差色",@"琥珀",@"美味",@"蜜桃粉",@"奶茶",@"拍立得",@"乌托邦",@"西柚",@"日杂",@"黑猫",@"黑白",@"布鲁克林",@"平静",@"冷酷",@"凯文",@"恋爱"];
        
        NSMutableArray * selectedItemArray = [MHSDK shareInstance].filterArray;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MHFilterParams" ofType:@"plist"];
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
            MHBeautiesModel *model = [MHBeautiesModel new];
            model.imgName = itemDic[@"imageName"];
            model.beautyTitle = itemDic[@"name"];
            model.isSelected = i == 0 ? YES : NO;
            model.type = [itemDic[@"type"] integerValue];
            model.menuType = MHBeautyMenuType_Filter;
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
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHFilterCell"];
    }
    return _collectionView;
}

@end
