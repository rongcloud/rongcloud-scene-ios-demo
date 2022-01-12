//
//  RCMusicRemoteViewController.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import "RCMusicRemoteViewController.h"
#import "RCMusicRemoteListCell.h"
#import "RCMusicCategorySelector.h"
#import "RCMusicDataManager.h"
#import "RCMusicDefine.h"
#import <Masonry/Masonry.h>
#import "RCMusicInfo.h"
#import "RCMusicDetail.h"
#import "RCMusicSearchBar.h"
#import "RCMusicRemoteEmptyView.h"
#import "RCMusicEngine.h"
#import "RCMusicCategoryInfo.h"
#import "SVProgressHUD.h"
#import "UIImage+RCMBundle.h"
#import "RCMusicListAppearance.h"

#define rcm_DataSource [RCMusicEngine shareInstance].dataSource
#define rcm_Delegate [RCMusicEngine shareInstance].delegate
#define rcm_Player [RCMusicEngine shareInstance].player

@interface RCMusicRemoteViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, RCMusicCategorySelectorDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *tableFooterView;
@property (nonatomic, strong) RCMusicSearchBar *searchBar;
@property (nonatomic, strong) RCMusicCategorySelector *categorySelector;
@property (nonatomic, strong) RCMusicRemoteEmptyView *emptyView;
@property (nonatomic, strong) RCMusicListAppearance *appearance;
@property (nonatomic, strong) NSMutableDictionary *musicsDict;
@property (nonatomic, assign, getter=isSearching) BOOL search;
@property (atomic, copy) NSArray<RCMusicCategoryInfo> *categories;
@property (atomic, copy) NSArray<RCMusicInfo> *musics;
@property (atomic, copy) NSString *currentCategoryId;
@end

@implementation RCMusicRemoteViewController

- (void)dealloc {
    NSLog(@"RCMusicRemoteViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildLayout];
    [self fetchSheets];
    [self registerNotification];
    self.musicsDict = [@{} mutableCopy];
    
}


#pragma Register Notification

- (void)registerNotification {
    //本地收藏音乐发生变化 同步已下载状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:RCMusicLocalDataChangedNotification object:nil];
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

#pragma mark FETCH DATA
//获取音乐类别数据
- (void)fetchSheets {
    if (rcm_DataSource != nil && [rcm_DataSource respondsToSelector:@selector(fetchCategories:)]) {
        [rcm_DataSource fetchCategories:^(NSArray<RCMusicCategoryInfo> * _Nullable categories) {
            self.categories = categories;
            if (self.categories != nil && self.categories.count > 0 && rcm_DataSource != nil && [rcm_DataSource respondsToSelector:@selector(fetchOnlineMusicsByCategoryId:completion:)]) {
                id <RCMusicCategoryInfo> obj = self.categories.firstObject;
                self.currentCategoryId = obj.categoryId;
                self.categorySelector.items = self.categories;
                [self fetchMusicWithCategoryId:self.currentCategoryId];
            }
        }];
    }
}

#pragma mark - DOWNLOAD MUSIC
//下载音乐
- (void)downloadMusic:(id<RCMusicInfo>)info {
    if ([rcm_DataSource respondsToSelector:@selector(fetchMusicDetailWithInfo:completion:)]) {
        //获取音乐详细信息
        [rcm_DataSource fetchMusicDetailWithInfo:info completion:^(id<RCMusicInfo>  _Nonnull music) {
            //成功获取到详细信息后下载音频文件
            [rcm_Delegate downloadedMusic:info completion:^(BOOL success) {
                if (success) {
                    [SVProgressHUD showSuccessWithStatus:@"下载歌曲成功"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //更新 下载已下载按钮状态
                        info.isLocal = @(YES);
                        if ([rcm_DataSource respondsToSelector:@selector(fetchCollectMusics:)]) {
                            //当本地音乐列表为空时，下载第一个歌曲后直接播放
                            [rcm_DataSource fetchCollectMusics:^(NSArray<RCMusicInfo> * _Nullable musics) {
                                if (musics.count == 1) {
                                    [rcm_Player startMixingWithMusicInfo:info];
                                }
                            }];
                        }
                    });
                }
            }];
        }];
    }
}

#pragma mark - CATEGORYSELECTOR RELOADDATA
//根据类别id 获取列表数据
- (void)fetchMusicWithCategoryId:(NSString *)sheetId {
    [rcm_DataSource fetchOnlineMusicsByCategoryId:sheetId completion:^(NSArray<RCMusicInfo> * _Nullable musics) {
        self.musics = musics;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
}

#pragma mark TABLEVIEW DATASOURCE
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.hidden = (self.musics == nil || self.musics.count == 0);
    self.emptyView.hidden = !self.tableView.hidden;
    return self.musics == nil ? 0 : self.musics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMusicRemoteListCell *cell = (RCMusicRemoteListCell *)[tableView dequeueReusableCellWithIdentifier:RCMusicRemoteListCell.identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    WeakSelf(self)
    if (indexPath.row < self.musics.count) {
        id<RCMusicInfo> info = self.musics[indexPath.row];
        [cell setDownloadButtonClick:^(NSString * _Nonnull musicId, BOOL isDownload) {
            StrongSelf(weakSelf)
            if (isDownload) {
                [strongSelf downloadMusic:info];
            } else {

            }
        }];
        info.isLocal = @([rcm_DataSource musicIsExist:info]);
        cell.info = info;
    } else {
        NSAssert(NO, @"歌曲数据异常");
    }
    return cell;
}

#pragma mark - CATEGORY SELECTOR DELEGATE
//切换类别
- (void)categoryDidSelectItemAtIndex:(NSInteger)index {
    id <RCMusicCategoryInfo> obj = self.categories[index];
    if (![self.currentCategoryId isEqualToString:obj.categoryId]) {
        self.musics = nil;
        [self.tableView reloadData];
        self.currentCategoryId = obj.categoryId;
        [self fetchMusicWithCategoryId:self.currentCategoryId];
    }
}

#pragma mark - SEARCHBAR DELEGATE
//开始编辑弹出搜索列表
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.search = YES;
    self.musics = nil;
    [self.tableView reloadData];
    [self.categorySelector mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    return YES;
}

//编辑结束搜索相应的keyword
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [rcm_DataSource fetchSearchResultWithKeyWord:searchBar.text completion:^(NSArray<RCMusicInfo> * _Nonnull musics) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.musics = musics;
            [self.tableView reloadData];
        });
    }];
    [searchBar resignFirstResponder];
}

//收起搜索列表
- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    if (self.isSearching) {
        searchBar.text = nil;
        self.search = NO;
        [self.categorySelector mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(48);
        }];
        [self fetchMusicWithCategoryId:self.currentCategoryId];
    }
}

#pragma mark LAYOUT SUBVIEWS

- (void)buildLayout {
    
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    
    [self.view addSubview:self.categorySelector];
    [self.categorySelector mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.top.equalTo(self.searchBar.mas_bottom);
        make.height.mas_equalTo(48);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.top.mas_equalTo(self.categorySelector.mas_bottom);
    }];
}

#pragma mark -GETTER

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[RCMusicRemoteListCell class] forCellReuseIdentifier:RCMusicRemoteListCell.identifier];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 74, 0, 0);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        if (self.appearance.turnOnLocalUpload && [rcm_DataSource respondsToSelector:@selector(addLocalMusic:)]) {
            _tableView.tableFooterView = self.tableFooterView;
        }
    }
    return _tableView;
}

- (UIView *)tableFooterView {
    if (_tableFooterView == nil) {
        
        RCMusicRemoteListCell *footerView = [[RCMusicRemoteListCell alloc] init];
        footerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
        WeakSelf(self)
        [footerView setDownloadButtonClick:^(NSString * _Nonnull musicId, BOOL isDownload) {
            StrongSelf(weakSelf)
            [rcm_DataSource addLocalMusic:strongSelf];
        }];
        
        [footerView setDocumentIcon:[UIImage rcm_imageNamed:@"doucment"]];
        UIView *line = [[UIView alloc] init];
        line.frame = CGRectMake(74, 0, self.view.bounds.size.width - 74, 0.5);
        line.backgroundColor = [[UITableView new].separatorColor colorWithAlphaComponent:0.5];
        [footerView addSubview:line];
        
        UILabel *contentLabel = [[UILabel alloc] init];
        contentLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        contentLabel.textColor = self.appearance.titleLabelTextColor;
        contentLabel.text = @"本地上传";
        contentLabel.frame =  CGRectMake(72, 12, 100, 40);
        [footerView addSubview:contentLabel];
        
        _tableFooterView = footerView;
    }
    return _tableFooterView;
}

- (RCMusicCategorySelector *)categorySelector {
    if (_categorySelector == nil) {
        _categorySelector = [[RCMusicCategorySelector alloc] init];
        _categorySelector.delegate = self;
    }
    return _categorySelector;
}

- (RCMusicSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[RCMusicSearchBar alloc] init];
        _searchBar.delegate = self;
    }
    return _searchBar;
}

- (RCMusicRemoteEmptyView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[RCMusicRemoteEmptyView alloc] init];
    }
    return _emptyView;
}

- (RCMusicListAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicListAppearance alloc] init];
    }
    return _appearance;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
