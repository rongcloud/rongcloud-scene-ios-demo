//
//  MHSpecificEffectView.m


#import "MHSpecificEffectView.h"
#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"

@interface MHSpecificEffectView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *specificArr;//存特效数据模型
@property (nonatomic, assign) NSInteger lastIndex;

@end
@implementation MHSpecificEffectView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.lastIndex = 0;
    }
    return self;
}
#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.specificArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHSpecificCell" forIndexPath:indexPath];
    cell.menuModel = self.specificArr[indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width-20) /6, MHSpecificCellHeight);
}
#pragma mark - delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *model = self.specificArr[indexPath.row];
    model.isSelected = !model.isSelected;

    if ([self.delegate respondsToSelector:@selector(handleSpecific:)]) {
            [self.delegate handleSpecific:model.type];
        }
    MHBeautiesModel *lastModel = self.specificArr[self.lastIndex];
    lastModel.isSelected = !lastModel.isSelected;
    
    [self.collectionView reloadData];
    self.lastIndex = indexPath.row;
}
#pragma mark - lazy

-(NSMutableArray *)specificArr {
    if (!_specificArr) {
//        NSArray *arr = @[@"noSpecific",@"chuqiao",@"doudong",@"shanbai",@"maoci", @"huanjue",@"mosaic",@"mosaic_circle",@"mosaic_sanjiao",@"mosaic_liubian"];
//        NSArray *filtersArr = @[@"无",@"灵魂出窍",@"抖动",@"闪白",@"毛刺",@"幻觉",@"马赛克1",@"马赛克2",@"马赛克3",@"马赛克4"];
        
        NSMutableArray * selectedItemArray = [MHSDK shareInstance].specificEffectArray;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MHSpecificEffecParams" ofType:@"plist"];
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
        
        
        _specificArr = [NSMutableArray array];
        for (int i = 0; i<selectedItems.count; i++) {
            NSDictionary * itemDic = selectedItems[i];
            MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
            model.imgName = itemDic[@"imageName"];
            model.beautyTitle = itemDic[@"name"];
            model.isSelected = i == 0 ? YES : NO;
            model.type = [itemDic[@"type"] integerValue];
            model.menuType = MHBeautyMenuType_Specify;
            [_specificArr addObject:model];
        }
    }
    return _specificArr;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(20, 10, 0, 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width,self.frame.size.height) collectionViewLayout:layout];
        ///修改MHUI
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHSpecificCell"];
    }
    return _collectionView;
}

@end
