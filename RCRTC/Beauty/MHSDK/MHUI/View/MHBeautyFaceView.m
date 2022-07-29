//
//  MHBeautyFaceView.m



#import "MHBeautyFaceView.h"
#import "MHBeautySlider.h"
#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"
#import "MHBeautiesModel.h"
static NSString *OriginalImg = @"face_origin";
static NSString *BigEyeImg = @"face_bigEye";
static NSString *FaceImg = @"face_thinFace";
static NSString *MouthImg = @"face_mouth";
static NSString *NoseImg = @"face_thinNose";
static NSString *ChinImg = @"face_chin";
static NSString *ForeheadImg = @"face_forehead";
static NSString *Eyebrow = @"face_eyebrow";
static NSString *Canthus = @"face_canthus";
static NSString *EyeAlae = @"face_eyeAlea";
static NSString *EyeDistance = @"face_eyeDistance";
static NSString *ShaveFace = @"face_shaveFace";
static NSString *Longnose = @"face_longnose";

@interface MHBeautyFaceView ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, strong) MHBeautySlider *slider;
@property (nonatomic, assign) NSInteger beautyType;
@end
@implementation MHBeautyFaceView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.lastIndex = -1;
      
    }
    return self;
}

- (void)configureFaceData {
    if (IsArrayWithAnyItem(self.array)) {
        return;//保证只初始化加载一次
    }
    NSMutableArray * selectedItemArray = [MHSDK shareInstance].faceArr;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MHFaceParams" ofType:@"plist"];
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
        NSDictionary * itemDic = items[i];
        MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
        model.imgName = itemDic[@"imageName"];
        model.beautyTitle = itemDic[@"name"];
        model.menuType = MHBeautyMenuType_Face;
        model.type = [itemDic[@"type"] integerValue];
        model.originalValue = itemDic[@"value"];
//       保存美颜数据
        NSString *faceKey = [NSString stringWithFormat:@"face_%ld",model.type];
        NSInteger originalValue = [[NSUserDefaults standardUserDefaults] integerForKey:faceKey];
        model.originalValue = [NSString stringWithFormat:@"%ld",originalValue];
        [[NSUserDefaults standardUserDefaults] setInteger:originalValue forKey:faceKey];
        [_array addObject:model];
    }
    [self.collectionView reloadData];
}

- (void)clearAllFaceEffects {
    for (int i = 0; i<self.array.count; i++) {
        MHBeautiesModel *model = self.array[0];
        NSString *faceKey = [NSString stringWithFormat:@"face_%ld",model.type];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:faceKey];
    }
}

- (void)cancelSelectedFaceType:(NSInteger)type {
    for (int i = 0; i<self.array.count; i++) {
        MHBeautiesModel *model = self.array[i];
        if (model.type == type) {
            model.isSelected = NO;
        }
    }
    self.lastIndex = -1;
    [self.collectionView reloadData];
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
    return CGSizeMake((window_width - 20 - 5*20)/4, MHMeiyanMenusCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *currentModel = self.array[indexPath.row];
    currentModel.isSelected = YES;
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = NO;
    }
    
    self.lastIndex = indexPath.row;
    [self.collectionView reloadData];
    self.beautyType = currentModel.type;
    if (indexPath.row == 0) {
        [self clearAllFaceEffects];
    }
    NSString *faceKey = [NSString stringWithFormat:@"face_%ld",(long)self.beautyType];
    NSInteger currentValue = [[NSUserDefaults standardUserDefaults] integerForKey:faceKey];
    if ([self.delegate respondsToSelector:@selector(handleFaceEffects:sliderValue:name:)]) {
        [self.delegate handleFaceEffects:self.beautyType  sliderValue:currentValue name:currentModel.beautyTitle];
    }
}

#pragma mark - lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 20;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(20, 20,20,20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        ///修改MHUI
        _collectionView.backgroundColor = [UIColor clearColor];;;;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
    }
    return _collectionView;
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

- (NSInteger)currentIndex
{
    return _lastIndex;
}

@end
