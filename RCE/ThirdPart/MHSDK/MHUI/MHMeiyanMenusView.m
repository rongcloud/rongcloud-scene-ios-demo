//
//  MHMeiyanMenusView.m

#import "MHMeiyanMenusView.h"
#import "MHBeautyMenuCell.h"
#import "MHStickersView.h"
#import "MHBeautyParams.h"
#import "StickerDataListModel.h"
#import "StickerManager.h"
#import "MHMagnifiedView.h"
#import "MHBeautyAssembleView.h"
#import "MHSpecificAssembleView.h"
#import "MHBeautiesModel.h"
#import "MHFilterModel.h"
#import <MHBeautySDK/MHBeautySDK.h>
#import "MHMakeUpView.h"

static NSString *StickerImg = @"stickerFace";
static NSString *BeautyImg = @"beauty1";
static NSString *FaceImg = @"face";
static NSString *CameraImg = @"beautyCamera";
static NSString *FilterImg = @"filter";
static NSString *SpecificImg = @"specific";
static NSString *HahaImg = @"haha";
static NSString *MakeUpImg =@"beautyMakeup";


@interface MHMeiyanMenusView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) MHBeautyManager *beautyManager;//美型特性管理器，必须传入

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *currentView;
@property (nonatomic, strong) UIView *superView;

@property (nonatomic, strong) MHBeautyAssembleView *beautyAssembleView;//美颜集合
@property (nonatomic, strong) MHSpecificAssembleView *specificAssembleView;//特效集合
@property (nonatomic, strong) MHStickersView *stickersView;//贴纸
@property (nonatomic, strong) MHMakeUpView *makeUpView;//美妆

@property (nonatomic, assign) int sdkLevelTYpe;///<sdk类型
@property (nonatomic, assign) NSInteger lastIndex;//上一个index

@property (nonatomic, strong) UILabel * statusLabel;

/*
 美狐sdk底部选项框内容信息数组
 */
@property (nonatomic, strong) NSMutableArray *array;

///设置默认美型或者美颜数据，供外部调用，需要在m文件的该方法中完善数据
- (void)setupDefaultBeautyAndFaceValue;

@end
@implementation MHMeiyanMenusView

- (instancetype)initWithManager:(MHBeautyManager *)manager
                       delegate:(id<MHMeiyanMenusViewDelegate>)delegate {
    if (self = [super init]) {
        self.lastIndex = -1;
        self.beautyManager = manager;
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)setupDefaultBeautyAndFaceValue {
    [_beautyManager setBuffing:0.7];
    [_beautyManager setSkinWhiting:0.7];
    [_beautyManager setRuddiness:0.5];
    [_beautyManager setBrightnessLift:0.5];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautyMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MHBeautyMenuCell"
                                                                       forIndexPath:indexPath];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (collectionView.bounds.size.width - 40) / self.array.count;
    CGFloat height = collectionView.bounds.size.height;
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MHBeautiesModel *currentModel = self.array[indexPath.row];
    if ([currentModel.beautyTitle isEqual:@""]) {
        return;
    }
    else if([currentModel.beautyTitle isEqual:@"单击拍"]){
        return;
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"特效")]){
        [self showBeautyViews:self.specificAssembleView];
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"贴纸")]){
        [self showBeautyViews:self.stickersView];
    }else if ([currentModel.beautyTitle isEqual:YZMsg(@"美颜")]){
        [self.beautyAssembleView configureUI];
        [self showBeautyViews:self.beautyAssembleView];
    } else if ([currentModel.beautyTitle isEqual:YZMsg(@"美妆")]){
        [self showBeautyViews:self.makeUpView];
    }
    
    currentModel.isSelected = YES;
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = NO;
    }
    self.lastIndex = indexPath.row;
    [self.collectionView reloadData];
}

#pragma mark - 切换美颜效果分类

- (void)showBeautyViews:(UIView *)currentView {
    
    [self.superView addSubview:currentView];
    CGRect rect = currentView.frame;
    rect.origin.y = window_height - currentView.frame.size.height - BottomIndicatorHeight;
    [currentView setFrame:rect];
    self.currentView = currentView;
    ///修改MHUI
    self.currentView.transform = CGAffineTransformMakeTranslation(0.00,  currentView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        
        self.currentView.transform = CGAffineTransformMakeTranslation(0.00, 0.00);
        
    }];
    if ([currentView isEqual:self.beautyAssembleView]) {
        [self.beautyAssembleView configureUI];
    }
}

#pragma mark - lazy
- (MHBeautyAssembleView *)beautyAssembleView {
    if (!_beautyAssembleView) {
        _beautyAssembleView = [[MHBeautyAssembleView alloc] initWithFrame:CGRectMake(0, window_height-MHBeautyAssembleViewHeight-BottomIndicatorHeight, window_width, MHBeautyAssembleViewHeight)];
        _beautyAssembleView.delegate = self;
    }
    return _beautyAssembleView;
}

- (MHStickersView *)stickersView {
    if (!_stickersView) {
        _stickersView = [[MHStickersView alloc] initWithFrame:CGRectMake(0, window_height-MHStickersViewHeight-BottomIndicatorHeight , window_width, MHStickersViewHeight)];
        _stickersView.delegate = self;
        ///修改MHUI
        _stickersView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
    }
    return _stickersView;
}


- (MHMakeUpView *)makeUpView {
    if (!_makeUpView) {
        _makeUpView = [[MHMakeUpView alloc] initWithFrame:CGRectMake(0, window_height-MHMagnifyViewHeight-BottomIndicatorHeight , window_width, MHMagnifyViewHeight)];
        _makeUpView.delegate = self;
        ///修改MHUI
        _makeUpView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:MHBlackAlpha];
    }
    return _makeUpView;
}


-(NSMutableArray *)array {
    if (!_array) {
        NSArray * itemArray = @[
            @{@"翻转":HahaImg},
            @{@"贴纸":StickerImg},
            @{@"美颜":BeautyImg},
            @{@"美妆":MakeUpImg},
            @{@"特效":SpecificImg},
        ];
        NSMutableArray * selectedItem = [MHSDK shareInstance].menuArray;
        NSMutableArray * arr = [NSMutableArray array];
        for (int i = 0; i < selectedItem.count; i++) {
            NSString * name = selectedItem[i][@"name"];
            for (int j = 0; j < itemArray.count; j++) {
                NSDictionary * dic = itemArray[j];
                NSString * imageName = dic[name];
                if (imageName) {
                    [arr addObject:dic];
                }
            }
        }
        
        _array = [NSMutableArray array];
        for (int i = 0; i<arr.count; i++) {
            NSDictionary * dic = arr[i];
            MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
            model.imgName = dic.allValues[0];
            model.beautyTitle = dic.allKeys[0];
            model.menuType = MHBeautyMenuType_Menu;
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
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0,20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
    }
    return _collectionView;
}

- (UILabel*)statusLabel{
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake((window_width - 60)/2, window_height - MHStickersViewHeight - BottomIndicatorHeight - 50, 60, 22)];
        _statusLabel.text = @"请张嘴";
        _statusLabel.hidden = YES;
    }
    return _statusLabel;
}

- (int)sdkLevelTYpe{
    return [[MHSDK shareInstance] getSDKLevel];
}
@end
