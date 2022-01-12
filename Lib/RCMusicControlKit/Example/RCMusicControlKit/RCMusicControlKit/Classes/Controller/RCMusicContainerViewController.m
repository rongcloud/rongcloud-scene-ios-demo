//
//  RCMusicContainerViewController.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import "RCMusicContainerViewController.h"
#import "RCMusicToolBarItem.h"
#import "RCMusicToolBar.h"
#import "UIImage+RCMBundle.h"
#import <Masonry/Masonry.h>
#import "RCMusicLocalViewController.h"
#import "RCMusicRemoteViewController.h"
#import "RCMusicControlViewController.h"
#import "RCMusicSoundEffectToolView.h"
#import "RCMusicDefine.h"
#import "RCMusicEngine.h"
#import "RCMusicEffectInfo.h"
#import "SVProgressHUD.h"
#import "RCMusicToolBarAppearance.h"
#import "RCMusicAppearanceData.h"

#define rcm_Player [RCMusicEngine shareInstance].player
#define rcm_DataSource [RCMusicEngine shareInstance].dataSource

@interface RCMusicContainerViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) RCMusicToolBar *toolBar;
@property (nonatomic, strong) RCMusicToolBarAppearance *appearance;
@property (nonatomic, strong) RCMusicSoundEffectToolView *soundEffectView;
@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) RCMusicPageType currentPageType;
@property (nonatomic, copy) NSArray<RCMusicEffectInfo> *effects;
@end

@implementation RCMusicContainerViewController

- (void)dealloc {
    NSLog(@"RCMusicContainerViewController dealloc");
}

- (instancetype)init {
    if (self = [super init]) {
        //设置 present 模式 和动画
        self.modalPresentationStyle = UIModalPresentationPopover;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildLayout];
    //默认展示本地收藏音乐页面
    self.currentPageType = RCMusicPageTypeLocalData;
    //获取音乐特效数据
    if ([rcm_DataSource respondsToSelector:@selector(fetchSoundEffectsWithCompletion:)]) {
        [rcm_DataSource fetchSoundEffectsWithCompletion:^(NSArray<RCMusicEffectInfo> * _Nullable effects) {
            self.effects = effects;
        }];
    }
}

#pragma mark - ITEM ACTIONS
//Tool Bar View Action
//切换到本地收藏页面
- (void)showLocalList {
    NSLog(@"show local list");
    self.currentPageType = RCMusicPageTypeLocalData;
}

//切换到在线音乐
- (void)showRemoteList {
    NSLog(@"show remote list");
    self.currentPageType = RCMusicPageTypeRemoteData;
}

//切换到音乐控制
- (void)showMusicControl {
    NSLog(@"show control");
    self.currentPageType = RCMusicPageTypeControl;
}

//弹出特效音乐 bar
- (void)soundEffectClick {
    NSLog(@"effect click");
    if (self.effects == nil || self.effects.count == 0) {
        [SVProgressHUD showErrorWithStatus:@"无特效数据"];
        return;
    }
    self.soundEffectView.hidden = !self.soundEffectView.hidden;
    if (!self.soundEffectView.hidden) {
        self.soundEffectView.items = self.effects;
    }
}

#pragma mark Self Delegate
//跳转页面
- (void)jumpToViewControllerWithPageType:(RCMusicPageType)pageType {
    self.currentPageType = pageType;
}

#pragma mark LAYOUT SUBVIEWS

//- (void)buildChildViewControllers {
//    RCMusicLocalViewController *local = [[RCMusicLocalViewController alloc] init];
//    local.delegate = self;
//    [self addChildViewController:local];
//    [self.scrollView addSubview:local.view];
//    [local.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.leading.width.height.equalTo(self.scrollView);
//    }];
//    [local didMoveToParentViewController:self];
//
//    RCMusicRemoteViewController *remote = [[RCMusicRemoteViewController alloc] init];
//    [self addChildViewController:remote];
//    [self.scrollView addSubview:remote.view];
//    [remote.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.width.height.equalTo(self.scrollView);
//        make.leading.equalTo(local.view.mas_trailing);
//    }];
//    [remote didMoveToParentViewController:self];
//
//    RCMusicControlViewController *control = [[RCMusicControlViewController alloc] init];
//    [self addChildViewController:control];
//    [self.scrollView addSubview:control.view];
//    [control.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.trailing.bottom.width.equalTo(self.scrollView);
//        make.leading.equalTo(remote.view.mas_trailing);
//    }];
//    [control didMoveToParentViewController:self];
//
//    [remote.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.equalTo(control.view.mas_leading);
//    }];
//}

- (void)buildChildViewControllers {
    
    UIView *contentView = [[UIView alloc] init];
    
    [self.scrollView addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.height.equalTo(self.scrollView);
    }];
    
    RCMusicLocalViewController *local = [[RCMusicLocalViewController alloc] init];
    local.delegate = self;
    
    RCMusicRemoteViewController *remote = [[RCMusicRemoteViewController alloc] init];
    
    NSArray *viewControllers;
    
    if (self.appearance.turnOnMusicControl) {
        RCMusicControlViewController *control = [[RCMusicControlViewController alloc] init];
        viewControllers = @[local,remote,control];
    } else {
        viewControllers = @[local,remote];
    }
    
    UIView *previousView =nil;
    
    for (int i = 0; i <viewControllers.count; i++) {
        
        UIViewController *vc = viewControllers[i];
        
        [self addChildViewController:vc];
        
        [contentView addSubview:vc.view];
        
        [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.bottom.equalTo(contentView);
            make.width.equalTo(self.scrollView);
            if (previousView) {
                make.leading.mas_equalTo(previousView.mas_trailing);
            }
            else {
                make.leading.mas_equalTo(0);
            }
        }];
        
        previousView = vc.view;
        
        [vc didMoveToParentViewController:self];
    }
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(previousView.mas_trailing);
    }];
}

- (void)buildLayout {
    [self.view addSubview:self.soundEffectView];
    [self.soundEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(200);
        make.leading.equalTo(self.view).offset(4);
        make.trailing.equalTo(self.view).offset(-4);
        make.height.mas_equalTo(60);
    }];
    [self.view addSubview:self.toolBar];
    [self.toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.soundEffectView.mas_bottom).offset(4);
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [self.view addSubview:self.backgroundView];
    [self.backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBar.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBar.mas_bottom);
        make.leading.bottom.trailing.equalTo(self.view);
        make.width.equalTo(self.view);
    }];
    
    [self buildChildViewControllers];
}

#pragma mark -GETTER

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

//出事换 tool bar items
- (RCMusicToolBar *)toolBar {
    if (_toolBar == nil) {
        RCMusicToolBarItem *item1 = [self createItemWithItem:self.appearance.items[0] record:YES selector:@selector(showLocalList)];
        RCMusicToolBarItem *item2 = [self createItemWithItem:self.appearance.items[1] record:YES selector:@selector(showRemoteList)];
        RCMusicToolBarItem *item3 = [self createItemWithItem:self.appearance.items[2] record:YES selector:@selector(showMusicControl)];
        RCMusicToolBarItem *item4 = [self createItemWithItem:self.appearance.items[3] record:NO selector:@selector(soundEffectClick)];
        NSMutableArray *leftItems = [@[item1,item2] mutableCopy];
        NSMutableArray *rightItems = [@[] mutableCopy];
        if (self.appearance.turnOnMusicControl) {
            [leftItems addObject:item3];
        }
        if (self.appearance.turnOnSoundEffect && [rcm_DataSource respondsToSelector:@selector(fetchSoundEffectsWithCompletion:)]) {
            [rightItems addObject:item4];
        }
        _toolBar = [[RCMusicToolBar alloc] initWithLeftItems:[leftItems copy] rightItems:[rightItems copy]];
    }
    return _toolBar;
}

- (RCMusicToolBarItem *)createItemWithItem:(RCMusicBarItem *)itemData record:(BOOL)record selector:(SEL)selector {
    RCMusicToolBarItem *item = [[RCMusicToolBarItem alloc] initWithNormalImage:itemData.normalImage.source selectedImage:itemData.selectedImage.source record:record target:self action:selector];
    return item;
}

- (UIVisualEffectView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular]];
        _backgroundView.alpha = 0.90;
    }
    return _backgroundView;
}

- (RCMusicSoundEffectToolView *)soundEffectView {
    if (_soundEffectView == nil) {
        _soundEffectView = [[RCMusicSoundEffectToolView alloc] init];
        _soundEffectView.layer.masksToBounds = YES;
        _soundEffectView.layer.cornerRadius = 6;
        _soundEffectView.hidden = YES;
        [_soundEffectView setItemClick:^(id<RCMusicEffectInfo>  _Nonnull info) {
            if (info.filePath) {
                [rcm_Player playEffect:info.soundId filePath:info.filePath];
            }
        }];
    }
    return _soundEffectView;
}

- (RCMusicToolBarAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicToolBarAppearance alloc] init];
    }
    return _appearance;
}
#pragma mark - SETTER

- (void)setCurrentPageType:(RCMusicPageType)currentPageType {
    _currentPageType = currentPageType;
    for (int i = 0; i < self.toolBar.leftItems.count; i++) {
        if (currentPageType == i) {
            RCMusicToolBarItem *item = self.toolBar.leftItems[i];
            item.selected = YES;
            break;
        }
    }
    CGFloat  width = [UIScreen mainScreen].bounds.size.width;
    [UIView animateWithDuration:.3f animations:^{
        [self.scrollView setContentOffset:CGPointMake(width*currentPageType, 0)];
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentPageType = scrollView.contentOffset.x/self.scrollView.bounds.size.width;
}
@end
