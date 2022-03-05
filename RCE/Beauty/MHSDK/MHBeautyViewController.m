//
//  MHBeautyViewController.m
//  RCE
//
//  Created by shaoshuai on 2022/1/30.
//

#import <MHBeautySDK/MHBeautySDK.h>

#import "MHBeautyViewController.h"

#import "MHBeautyMenuCell.h"
#import "MHBeautyParams.h"

#import "StickerManager.h"
#import "StickerDataListModel.h"

#import "MHMakeUpView.h"
#import "MHStickersView.h"
#import "MHMagnifiedView.h"
#import "MHBeautyAssembleView.h"
#import "MHSpecificAssembleView.h"

#import "MHFilterModel.h"
#import "MHBeautiesModel.h"

#define RCMHThemeColor \
[UIColor colorWithRed: 3.0/255 green:6.0/255 blue:47.0/255 alpha:1]

#define kBasicStickerURL @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBpL3Nkay92MS9zdGlja2VyL2luZGV4"

static NSString *StickerImg = @"menu_sticker";
static NSString *BeautyImg = @"menu_beauty";
static NSString *FaceImg = @"face";
static NSString *CameraImg = @"beautyCamera";
static NSString *FilterImg = @"menu_filter";
static NSString *SpecificImg = @"menu_special";
static NSString *HahaImg = @"haha";
static NSString *MakeUpImg =@"beautyMakeup";

@interface MHBeautyViewController ()
<
MHBeautyAssembleViewDelegate,
MHStickersViewDelegate,
MHMagnifiedViewDelegate,
MHSpecificAssembleViewDelegate,
MHBeautyManagerDelegate,
MHMakeUpViewDelegate
>

@property (nonatomic, strong) MHBeautyManager *beautyManager;//美型特性管理器，必须传入

@property (nonatomic, strong) MHMagnifiedView *magnifiedView;//哈哈镜
@property (nonatomic, strong) MHBeautyAssembleView *beautyAssembleView;//美颜集合
@property (nonatomic, strong) MHSpecificAssembleView *specificAssembleView;//特效集合
@property (nonatomic, strong) MHStickersView *stickersView;//贴纸
@property (nonatomic, strong) MHMakeUpView *makeUpView;//美妆

@property (nonatomic, strong) UIView *currentView;

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation MHBeautyViewController

- (instancetype)initWithManager:(MHBeautyManager *)manager {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.beautyManager = manager;
        self.beautyManager.delegate = self;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupMHStickData];
    [self setupMHAssembleData];
}

- (void)setupMHStickData {
    if ([MHSDK shareInstance].stickerArray.count == 0) return;
    
    NSDictionary * itemDic = [MHSDK shareInstance].stickerArray[0];
    
    NSString *baseURLString = @"https://data.facegl.com";
    NSString *pathURLString = itemDic[@"mark"];
    NSString *urlString = [baseURLString stringByAppendingString:pathURLString];
    
    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    urlString = [data base64EncodedStringWithOptions:0];
    
    dispatch_queue_t queue = dispatch_queue_create("rc.beauty.sticker", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        [[StickerManager sharedManager] requestStickersListWithUrl:urlString Success:^(NSArray<StickerDataListModel *> * _Nonnull stickerArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.stickersView configureStickers:stickerArray];
            });
        } Failed:^{}];
    });
}

- (void)setupMHAssembleData {
    for (MHBeautiesModel *model in self.array) {
        NSString * itemName = model.beautyTitle;
        if ([itemName isEqualToString:@"特效"]){
            [self.specificAssembleView getActionSource];
            break;
        }
    }
}

#pragma mark - delegate

- (void)handleBeautyWithType:(NSInteger)type level:(CGFloat)beautyLevel {
    switch (type) {
        case MHBeautyType_Original:{
            [_beautyManager setRuddiness:0];
            [_beautyManager setSkinWhiting:0];
            [_beautyManager setBuffing:0.0];
        }
            break;
            
        case MHBeautyType_Mopi:
            [_beautyManager setBuffing:beautyLevel];
            
            break;
        case MHBeautyType_White:
            [_beautyManager setSkinWhiting:beautyLevel];
            break;
        case MHBeautyType_Ruddiess:
            [_beautyManager setRuddiness:beautyLevel];
            break;
        case MHBeautyType_Brightness:
            [_beautyManager setBrightnessLift:beautyLevel];
            break;
            
        default:
            break;
    }
}

//美型
-(void)handleFaceBeautyWithType:(NSInteger)type sliderValue:(NSInteger)value {
    self.beautyManager.isUseFaceBeauty = YES;
    switch (type) {
        case MHBeautyFaceType_Original:{
            //原图-->人脸识别设置
            self.beautyManager.isUseFaceBeauty = NO;
            [self.beautyManager setFaceLift:0];
            [self.beautyManager setBigEye:0];
            [self.beautyManager setMouthLift:0];
            [self.beautyManager setNoseLift:0];
            [self.beautyManager setChinLift:0];
            [self.beautyManager setForeheadLift:0];
            [self.beautyManager setEyeBrownLift:0];
            [self.beautyManager setEyeAngleLift:0];
            [self.beautyManager setEyeAlaeLift:0];
            [self.beautyManager setShaveFaceLift:0];
            [self.beautyManager setEyeDistanceLift:0];
        }
            break;
        case MHBeautyFaceType_ThinFace:
            [self.beautyManager setFaceLift:(int)value];
            break;
        case MHBeautyFaceType_BigEyes:
            [self.beautyManager setBigEye:(int)value];
            break;
        case MHBeautyFaceType_Mouth:
            [self.beautyManager setMouthLift:(int)value];
            break;
        case MHBeautyFaceType_Nose:
            [self.beautyManager setNoseLift:(int)value];
            break;
        case MHBeautyFaceType_Chin:
            [self.beautyManager setChinLift:(int)value];
            break;
        case MHBeautyFaceType_Forehead:
            [self.beautyManager setForeheadLift:(int)value];
            break;
        case MHBeautyFaceType_Eyebrow:
            [self.beautyManager setEyeBrownLift:(int)value];
            break;
        case MHBeautyFaceType_Canthus:
            [self.beautyManager setEyeAngleLift:(int)value];
            break;
        case MHBeautyFaceType_EyeAlae:
            [self.beautyManager setEyeAlaeLift:(int)value];
            break;
        case MHBeautyFaceType_EyeDistance:
            [self.beautyManager setEyeDistanceLift:(int)value];
            break;
        case MHBeautyFaceType_ShaveFace:
            [self.beautyManager setShaveFaceLift:(int)value];
            break;
        case MHBeautyFaceType_LongNose:
            [self.beautyManager setLengthenNoseLift:(int)value];
            break;
        default:
            break;
    }
    
}

//一键美颜
- (void)handleQuickBeautyValue:(MHBeautiesModel *)model {
    if (model.type == 0){
        self.beautyManager.isUseOneKey = NO;
    }else{
        self.beautyManager.isUseOneKey = YES;
    }
    [self.beautyManager setFaceLift:model.face_defaultValue.intValue];
    [self.beautyManager setBigEye:model.bigEye_defaultValue.intValue];
    [self.beautyManager setMouthLift:model.mouth_defaultValue.intValue];
    [self.beautyManager setNoseLift:model.nose_defaultValue.intValue];
    [self.beautyManager setChinLift:model.chin_defaultValue.intValue];
    [self.beautyManager setForeheadLift:model.forehead_defaultValue.intValue];
    [self.beautyManager setEyeBrownLift:model.eyeBrown_defaultValue.intValue];
    [self.beautyManager setEyeAngleLift:model.eyeAngle_defaultValue.intValue];
    [self.beautyManager setEyeAlaeLift:model.eyeAlae_defaultValue.intValue];
    [self.beautyManager setShaveFaceLift:model.shaveFace_defaultValue.intValue];
    [self.beautyManager setEyeDistanceLift:model.eyeDistance_defaultValue.intValue];
    [self.beautyManager setRuddiness:(model.ruddinessValue.floatValue)/9.0];
    [self.beautyManager setSkinWhiting:(model.whiteValue.floatValue)/9.0];
    [self.beautyManager setBuffing:(model.buffingValue.floatValue)/9.0];
}


- (void)handleQuickBeautyWithSliderValue:(NSInteger)value quickBeautyModel:(nonnull MHBeautiesModel *)model{
    if (!model) {
        return;
    }
    if (value >= model.bigEye_minValue.integerValue && value <= model.bigEye_maxValue.integerValue) {
        [self.beautyManager setBigEye:(int)value];
        
    }
    if (value >= model.face_minValue.integerValue && value <= model.face_minValue.integerValue) {
        [self.beautyManager setFaceLift:(int)value];
        
    }
    if (value >= model.mouth_minValue.integerValue && value <= model.mouth_maxValue.integerValue) {
        [self.beautyManager setMouthLift:(int)value];
        
    }
    if (value >= model.shaveFace_minValue.integerValue && value <= model.shaveFace_maxValue.integerValue) {
        [self.beautyManager setShaveFaceLift:(int)value];
        
    }
    if (value >= model.eyeAlae_minValue.integerValue && value <= model.eyeAlae_maxValue.integerValue) {
        [self.beautyManager setEyeAlaeLift:(int)value];
        
    }
    if (value >= model.eyeAngle_minValue.integerValue && value <= model.eyeAngle_maxValue.integerValue) {
        [self.beautyManager setEyeAngleLift:(int)value];
        
    }
    if (value >= model.eyeBrown_minValue.integerValue && value <= model.eyeBrown_maxValue.integerValue) {
        [self.beautyManager setEyeBrownLift:(int)value];
        
    }
    if (value >= model.forehead_minValue.integerValue && value <= model.forehead_maxValue.integerValue) {
        [self.beautyManager setForeheadLift:(int)value];
        
    }
    if (value >= model.chin_minValue.integerValue && value <= model.chin_maxValue.integerValue) {
        [self.beautyManager setChinLift:(int)value];
        
    }
    if (value >= model.nose_minValue.integerValue && value <= model.nose_maxValue.integerValue) {
        [self.beautyManager setNoseLift:(int)value];
        
    }
    if (value >= model.eyeDistance_minValue.integerValue && value <= model.eyeDistance_maxValue.integerValue) {
        [self.beautyManager setEyeDistanceLift:(int)value];
        
    }
}
//滤镜
- (void)handleFiltersEffectWithType:(NSInteger)filter  withFilterName:(nonnull NSString *)filterName{
    MHFilterModel *model = [MHFilterModel unzipFiltersFile:filterName];
    if (model) {
        NSDictionary *dic = @{@"kUniformList":model.uniformList,
                              @"kUniformData":model.uniformData,
                              @"kUnzipDesPath":model.unzipDesPath,
                              @"kName":model.name,
                              @"kFragmentShader":model.fragmentShader
        };
        [_beautyManager setFilterType:filter newFilterInfo:dic];
    } else {
        [_beautyManager setFilterType:filter newFilterInfo:[NSDictionary dictionary]];
    }
}

//水印
- (void)handleWatermarkWithModel:(MHBeautiesModel *)model {
    [self.beautyManager setWatermarkRect:CGRectMake(0.08, 0.08, 0.1, 0.1)];
    [self.beautyManager setWatermark:model.imgName alignment:model.aliment];
}
//特效
- (void)handleSpecificWithType:(NSInteger)type {
    [self.beautyManager setJitterType:type];
}

//动作识别
- (void)handleSpecificStickerActionEffect:(NSString *)stickerContent
                                  sticker:(StickerDataListModel *)model
                                   action:(int)action{
    if (model == nil || action == 0){
        _beautyManager.isUseSticker = NO;
    }else{
        _beautyManager.isUseSticker = YES;
    }
    [self.beautyManager setSticker:stickerContent action:action];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.stickersView clearStikerUI];
    });
}

//美妆
- (void)handleMakeUpType:(NSInteger)type withON:(BOOL)On{
    if (type == 0) {
        self.beautyManager.isUseMakeUp = NO;
    }else{
        self.beautyManager.isUseMakeUp = YES;
    }
    [self.beautyManager setBeautyManagerMakeUpType:type withOn:On];
}

//特效里面的哈哈镜
- (void)handleMagnityWithType:(NSInteger)type{
    [self handleMagnify:type withIsMenu:NO];
}

//哈哈镜
-(void)handleMagnify:(NSInteger)type withIsMenu:(BOOL)isMenu{
    _beautyManager.isUseHaha = type != 0;
    [_beautyManager setDistortType:type withIsMenu:isMenu];
}

//贴纸
- (void)handleStickerEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model withLevel:(NSInteger)level{
    _beautyManager.isUseSticker = model != nil;
    [self.beautyManager setSticker:stickerContent withLevel:level];
    if (_specificAssembleView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->_specificAssembleView clearAllActionEffects];
        });
    }
}

#pragma mark - 切换美颜效果分类
- (void)showBeautyViews:(UIView *)currentView {
    [self.currentView removeFromSuperview];
    [self.view addSubview:currentView];
    
    CGRect rect = currentView.frame;
    rect.origin.y = window_height - currentView.frame.size.height - BottomIndicatorHeight;
    [currentView setFrame:rect];
    
    currentView.transform = CGAffineTransformMakeTranslation(0.00,  currentView.frame.size.height);
    [UIView animateWithDuration:0.3 animations:^{
        currentView.transform = CGAffineTransformIdentity;
    }];
    
    self.currentView = currentView;
}

#pragma mark - lazy

- (MHBeautyAssembleView *)beautyAssembleView {
    if (!_beautyAssembleView) {
        _beautyAssembleView = [[MHBeautyAssembleView alloc] initWithFrame:CGRectMake(0, window_height-MHBeautyAssembleViewHeight-BottomIndicatorHeight, window_width, MHBeautyAssembleViewHeight)];
        _beautyAssembleView.delegate = self;
        
    }
    return _beautyAssembleView;
}

- (MHSpecificAssembleView *)specificAssembleView {
    if (!_specificAssembleView) {
        _specificAssembleView = [[MHSpecificAssembleView alloc] initWithFrame:CGRectMake(0, window_height-MHSpecificAssembleViewHeight-BottomIndicatorHeight, window_width, MHSpecificAssembleViewHeight)];
        _specificAssembleView.delegate = self;
        ///修改MHUI
        _specificAssembleView.backgroundColor = [UIColor clearColor];;;;
    }
    return _specificAssembleView;
}
- (MHMagnifiedView *)magnifiedView {
    if (!_magnifiedView) {
        _magnifiedView = [[MHMagnifiedView alloc] initWithFrame:CGRectMake(0, window_height-MHMagnifyViewHeight-BottomIndicatorHeight, window_width, MHMagnifyViewHeight)];
        _magnifiedView.delegate = self;
        ///修改MHUI
        _magnifiedView.backgroundColor = [UIColor clearColor];;;;
    }
    return _magnifiedView;
}

- (MHStickersView *)stickersView {
    if (!_stickersView) {
        _stickersView = [[MHStickersView alloc] initWithFrame:CGRectMake(0, window_height-MHStickersViewHeight-BottomIndicatorHeight , window_width, MHStickersViewHeight)];
        _stickersView.delegate = self;
        ///修改MHUI
        _stickersView.backgroundColor = [UIColor clearColor];;;;
    }
    return _stickersView;
}


- (MHMakeUpView *)makeUpView {
    if (!_makeUpView) {
        _makeUpView = [[MHMakeUpView alloc] initWithFrame:CGRectMake(0, window_height-MHMagnifyViewHeight-BottomIndicatorHeight , window_width, MHMagnifyViewHeight)];
        _makeUpView.delegate = self;
        ///修改MHUI
        _makeUpView.backgroundColor = [UIColor clearColor];;;;
    }
    return _makeUpView;
}


- (NSMutableArray *)array {
    if (_array) return _array;
        
    NSArray *itemArray = @[
        @{@"贴纸":StickerImg },
        @{@"美颜":BeautyImg},
        @{@"":CameraImg},
        @{@"特效":SpecificImg},
        @{@"哈哈镜":HahaImg},
        @{@"美妆":MakeUpImg}
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
    if (_array.count == 0) {
        for (int i = 0; i<itemArray.count; i++) {
            NSDictionary * dic = itemArray[i];
            MHBeautiesModel *model = [[MHBeautiesModel alloc] init];
            model.imgName = dic.allValues[0];
            model.beautyTitle = dic.allKeys[0];
            model.menuType = MHBeautyMenuType_Menu;
            [_array addObject:model];
        }
    }
    
    return _array;
}

- (void)showItem:(RCMHBeautyType)item {
    switch (item) {
        case RCMHBeautyTypeEffect:
            [self showBeautyViews:self.specificAssembleView];
            break;
        case RCMHBeautyTypeMakeup:
            [self showBeautyViews:self.makeUpView];
            break;
        case RCMHBeautyTypeRetouch:
            [self.beautyAssembleView configureUI];
            [self showBeautyViews:self.beautyAssembleView];
            break;
        case RCMHBeautyTypeSticker:
            [self showBeautyViews:self.stickersView];
            break;
    }
    self.currentView.backgroundColor = RCMHThemeColor;
}

- (void)appleDefaultValues {
    NSArray *faceValues = @[@"0", @"28", @"37", @"58", @"0", @"27", @"80", @"0", @"55", @"0", @"77", @"0", @"20"];
    for (int i = 0; i < faceValues.count; i++) {
        if (i == 0) continue;
        NSString *value = faceValues[i];
        NSString *key = [NSString stringWithFormat:@"face_%d", i];
        [[NSUserDefaults standardUserDefaults] setInteger:value.integerValue forKey:key];
        [self handleFaceBeautyWithType:i sliderValue:value.integerValue];
    }
    
    NSArray *beautyValues = @[@"0",@"2",@"6",@"5",@"0"];
    for (int i = 0; i < beautyValues.count; i++) {
        if (i == 0) continue;
        NSString * value = beautyValues[i];
        NSString *key = [NSString stringWithFormat:@"beauty_%d", i];
        [[NSUserDefaults standardUserDefaults] setInteger:value.integerValue forKey:key];
        [self handleBeautyWithType:i level:(value.integerValue/10.0)];
    }
}

@end
