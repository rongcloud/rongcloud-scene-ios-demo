//
//  MHActionView.m
//  TXLiteAVDemo_UGC
//
//  Created by Apple on 2021/4/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "MHActionView.h"
#import "MHBeautyParams.h"
#import "MHBeautyMenuCell.h"
#import "MHBeautiesModel.h"
#import "StickerManager.h"
#import <MHBeautySDK/MHBeautySDK.h>
#import "StickerDataListModel.h"
static NSString *Cancel = @"beautyOrigin";
static NSString *Rise = @"actionRise";
static NSString *Month = @"actionMonth";
static NSString *Eye = @"actionEye";
#define kBasicStickerURL @"aHR0cHM6Ly9kYXRhLmZhY2VnbC5jb20vYXBpL3Nkay92MS9tb3Rpb24vaW5kZXg="
@interface MHActionView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, assign) NSInteger lastIndex;
@property (nonatomic, assign) NSInteger beautyType;
@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) NSMutableArray * actionArray;

@end
@implementation MHActionView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        self.backgroundColor = [UIColor clearColor];
        self.lastIndex = -1;
        [self getSticks];
    }
    return self;
}

#pragma mark - 贴纸解析
- (void)getSticks {

        __weak typeof(self) weakSelf = self;
       dispatch_async(dispatch_queue_create("com.suory.stickers", DISPATCH_QUEUE_SERIAL), ^{
           [[StickerManager sharedManager] requestStickersListWithUrl:kBasicStickerURL Success:^(NSArray<StickerDataListModel *> * _Nonnull stickerArray) {
               [weakSelf.actionArray removeAllObjects];
               NSMutableArray * arr = [NSMutableArray arrayWithArray:stickerArray];
               StickerDataListModel * model = arr[0];
               NSString *key = [NSString stringWithFormat:@"%@:%@",model.name,model.uptime];
               NSString *content = [[NSUserDefaults standardUserDefaults] objectForKey:key];
               //NSLog(@"stickercontent:---%@",content);
               if (content.length > 0) {//该贴纸已经下载过
                   model.is_downloaded = @"1";
               }else{
                   model.is_downloaded = @"0";
               }
               [arr replaceObjectAtIndex:0 withObject:model];
               [weakSelf.actionArray addObjectsFromArray:arr];
           } Failed:^{

           }];
       });

}


- (void)clearAllActionEffects {
    if (self.lastIndex>=0) {
        NSMutableArray * array = [NSMutableArray arrayWithArray:self.array];
        MHBeautiesModel * model = array[self.lastIndex];
        model.isSelected = NO;
        [array replaceObjectAtIndex:self.lastIndex withObject:model];
        self.array = array;
        self.lastIndex = -1;
        [self.collectionView reloadData];
    }
   
}

- (void)cancelSelectedBeautyType:(NSInteger)type {
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
    
    return CGSizeMake((window_width-40)/4, MHMeiyanMenusCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.actionArray.count ==0) {
        [self toastTip:@"资源下载中"];
        return;
    }
    
    if (self.lastIndex == indexPath.row) {
        return;
    }
    MHBeautiesModel *currentModel1 = self.array[indexPath.row];
    currentModel1.isSelected = YES;
    if (self.lastIndex >= 0) {
        MHBeautiesModel *lastModel = self.array[self.lastIndex];
        lastModel.isSelected = NO;
    }
    
    
    self.lastIndex = currentModel1.type;
    [self.collectionView reloadData];
    self.beautyType = indexPath.row;
    
    
    
    StickerDataListModel * currentModel = self.actionArray[0];
    
    if (indexPath.row == 0) {
        currentModel = self.actionArray[0];
    }else if (indexPath.row == 1) {
        currentModel = self.actionArray[2];
    }else if(indexPath.row == 2){
        currentModel = self.actionArray[0];
    }else if(indexPath.row == 3){
        currentModel = self.actionArray[1];
    }
    if (currentModel.is_downloaded.boolValue == NO) {
    
        [[StickerManager sharedManager] downloadSticker:currentModel index:indexPath.row withSuccessed:^(StickerDataListModel * _Nonnull sticker, NSInteger index) {
            sticker.downloadState = MHStickerDownloadStateDownoadDone;
            [self.actionArray replaceObjectAtIndex:0 withObject:sticker];
//            NSNumber *lastSelectedIndex = self.indexsArr.lastObject;
//            if (index == lastSelectedIndex.integerValue) {
                sticker.isSelected = YES;
                
                NSString *key = [NSString stringWithFormat:@"%@:%@",sticker.name,sticker.uptime];
            if ([self.delegate respondsToSelector:@selector(handleStickerActionEffect: sticker: action:)]) {
                    [self.delegate handleStickerActionEffect:key sticker:sticker action:(int)self.lastIndex];
                }
//            }
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (collectionView) {
                    for (NSIndexPath *path in collectionView.indexPathsForVisibleItems) {
                        if (index == path.item) {
                            [collectionView reloadData];
                            break;
                        }
                    }
                    
                }
                
            });
           
            self.lastIndex = indexPath.item;
            NSString *itemStr = [NSString stringWithFormat:@"%ld",(long)indexPath.item];
            [[NSUserDefaults standardUserDefaults] setObject:itemStr forKey:@"selectedStickerIndex"];
        } failed:^(StickerDataListModel * _Nonnull sticker, NSInteger index) {
            sticker.isSelected = NO;
            sticker.downloadState = MHStickerDownloadStateDownoadNot;
            [self.actionArray replaceObjectAtIndex:0 withObject:sticker];
            if (self.lastIndex >= 0) {
                StickerDataListModel *lastModel = self.actionArray[1];
                lastModel.isSelected = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionView reloadData];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"下载失败" message:@"请稍后重试" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
            });
            
        }];
    } else {

//        if (self.lastTag == 1114) {
            for (StickerDataListModel * model in self.actionArray) {
                if (model == currentModel) {
                    model.isSelected = YES;
                }else{
                    model.isSelected = NO;
                }
            }
//        }
        NSString *key = [NSString stringWithFormat:@"%@:%@",currentModel.name,currentModel.uptime];
        currentModel.isSelected = YES;
        if ([self.delegate respondsToSelector:@selector(handleStickerActionEffect:sticker:action:)]) {
            [self.delegate handleStickerActionEffect:key sticker:currentModel action:(int)self.lastIndex];
        }
        [collectionView reloadData];
         self.lastIndex = indexPath.item;
//        NSString *itemStr = [NSString stringWithFormat:@"%ld",(long)indexPath.item];
//        [[NSUserDefaults standardUserDefaults] setObject:itemStr forKey:@"selectedStickerIndex"];
    }
    
    
   
}
- (void) toastTip:(NSString*)toastInfo
{
    CGRect frameRC = [self bounds];
    frameRC.origin.y = frameRC.size.height - 240;
    frameRC.size.height -= 100;
    __block UITextView * toastView = [[UITextView alloc] init];

    toastView.editable = NO;
    toastView.selectable = NO;

    frameRC.size.height = [toastView sizeThatFits:CGSizeMake(frameRC.size.width, MAXFLOAT)].height;

    toastView.frame = frameRC;

    toastView.text = toastInfo;
    toastView.textAlignment = NSTextAlignmentCenter;
    toastView.font = [UIFont systemFontOfSize:17];
    toastView.backgroundColor = [UIColor clearColor];
 

    [self addSubview:toastView];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);

    dispatch_after(popTime, dispatch_get_main_queue(), ^(){
        [toastView removeFromSuperview];
        toastView = nil;
    });
}

#pragma mark - lazy
- (NSMutableArray *)array {
    if (!_array) {
        
        NSMutableArray * selectedItemArray = [MHSDK shareInstance].actionArray;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MHActionParams" ofType:@"plist"];
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
            model.type = [itemDic[@"type"] integerValue];
            model.menuType = MHBeautyMenuType_Action;
            [_array addObject:model];
        }
    }
    return _array;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.sectionInset = UIEdgeInsetsMake(20, 20,20,20);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, window_width,self.frame.size.height) collectionViewLayout:layout];
        ///修改MHUI
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[MHBeautyMenuCell class] forCellWithReuseIdentifier:@"MHBeautyMenuCell"];
    }
    return _collectionView;
}

- (NSInteger)currentIndex{
    return _lastIndex;
}


- (NSMutableArray*)actionArray{
    if (!_actionArray) {
        _actionArray = [NSMutableArray array];
    }
    return _actionArray;
}

@end
