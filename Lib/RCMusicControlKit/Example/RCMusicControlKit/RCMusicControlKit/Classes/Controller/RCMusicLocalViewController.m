//
//  RCMusicLocalViewController.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import "RCMusicLocalViewController.h"
#import "RCMusicDataManager.h"
#import "RCMusicLocalListCell.h"
#import <Masonry/Masonry.h>
#import "RCMusicDefine.h"
#import "RCMusicLocalEmptyView.h"
#import "RCMusicListAppearance.h"
#import "RCMusicEngine.h"
#import "RCMusicInfo.h"
#import "RCMusicDefine.h"

#define rcm_Delegate [RCMusicEngine shareInstance].delegate
#define rcm_Player [RCMusicEngine shareInstance].player
#define rcm_DataSource [RCMusicEngine shareInstance].dataSource

@interface RCMusicLocalViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) RCMusicLocalEmptyView *emptyView;
@property (nonatomic, strong) RCMusicListAppearance *appearance;
@property (atomic, copy) NSArray<RCMusicInfo> *musics;
@end

@implementation RCMusicLocalViewController

- (void)dealloc {
    NSLog(@"RCMusicLocalViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self buildLayout];
    [self registerNotification];
    [self reloadTableView];
}

#pragma mark REGISTER NOTIFICATION

- (void)registerNotification {
    //本地收藏音乐发生变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:RCMusicLocalDataChangedNotification object:nil];
    
    //音乐播放状态同步
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asyncMixState:) name:RCMusicAsyncMixStateNotification object:nil];
    
}

- (void)asyncMixState:(NSNotification *)notification {
    NSDictionary *dict = notification.object;
    RCMusicMixingState state = [(NSNumber *)dict[@"state"] integerValue];
    [self reloadTableView];
}

- (void)reloadTableView {
    if ([rcm_DataSource respondsToSelector:@selector(fetchCollectMusics:)]) {
        [rcm_DataSource fetchCollectMusics:^(NSArray<RCMusicInfo> * _Nullable musics) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.musics = musics;
                [self.tableView reloadData];
            });
        }];
    }
}

#pragma mark PRIVATE METHOD

//置顶音乐
- (void)top:(id <RCMusicInfo>)music {
    
    if (self.musics == nil || self.musics.count == 0) {
        return;
    }
    
    if ([rcm_Delegate respondsToSelector:@selector(topMusic:withMusic:completion:)]) {
        [rcm_Delegate topMusic:rcm_Player.currentPlayingMusic withMusic:music completion:^(BOOL success) {
            if (success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //调整cell位置
                    NSInteger idx1 = -1;
                    NSInteger idx2 = -1;
            
                    for (int i = 0; i < self.musics.count; i++) {
                        id<RCMusicInfo> info = self.musics[i];
                        if ([info isEqualToMusic:rcm_Player.currentPlayingMusic]) {
                            idx1 = i;
                        } else if ([info isEqualToMusic:music]) {
                            idx2 = i;
                        }
                    }
                    
                    if (idx1 != -1 && idx2 != -1 && idx2 != idx1 + 1) {
                        //删除被置顶的歌曲，插入到正在播放的下一位
                        NSIndexPath *deleteIndexPath = [NSIndexPath indexPathForRow:idx2 inSection:0];
                        NSIndexPath *insetIndexPath = idx1 == self.musics.count - 1 ? [NSIndexPath indexPathForRow:idx1 inSection:0] : [NSIndexPath indexPathForRow:idx1 + 1 inSection:0];
                        WeakSelf(self)
                        [self.tableView performBatchUpdates:^{
                            StrongSelf(weakSelf)
                            [strongSelf.tableView deleteRowsAtIndexPaths:@[deleteIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                            [strongSelf.tableView insertRowsAtIndexPaths:@[insetIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                        } completion:^(BOOL finished) {
                            if (rcm_Player.currentPlayingMusic == nil) {
                                [rcm_Player startMixingWithMusicInfo:music];
                            }
                        }];
                    } else {
                        //没有正在播放的歌曲，或者被置顶的音乐本身就在正在播放的音乐的下一位
                        if (rcm_Player.currentPlayingMusic == nil) {
                            [rcm_Player startMixingWithMusicInfo:music];
                        }
                    }
                });
            }
        }];
    }
}

//删除本地收藏音乐
- (void)_delete:(id <RCMusicInfo>)music {
    if ([rcm_Delegate respondsToSelector:@selector(deleteMusic:completion:)]) {
        [rcm_Delegate deleteMusic:music completion:^(BOOL success) {
            if (success) {
                NSLog(@"delete success");
            } else {
                NSLog(@"delete fail");
            }
        }];
    }
}

//播放音乐
- (void)play:(id <RCMusicInfo>)music {
    if ([rcm_Player respondsToSelector:@selector(startMixingWithMusicInfo:)]) {
        [rcm_Player startMixingWithMusicInfo:music];
    }
}

//停止播放
- (void)stop:(id <RCMusicInfo>)music {
    if ([rcm_Player respondsToSelector:@selector(stopMixingWithMusicInfo:)]) {
        [rcm_Player stopMixingWithMusicInfo:music];
    }
}

#pragma mark LAYOUT SUBVIEWS

- (void)buildLayout {
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - TABLEVIEW DELEGATE

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.hidden = self.musics == nil || self.musics.count == 0;
    self.emptyView.hidden = self.musics != nil && self.musics.count != 0;
    return self.musics == nil ? 0 : self.musics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMusicLocalListCell *cell = (RCMusicLocalListCell *)[tableView dequeueReusableCellWithIdentifier:RCMusicLocalListCell.identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.musics.count > indexPath.row) {
        id<RCMusicInfo> music = self.musics[indexPath.row];
        cell.music = music;
        cell.isPlaying = [rcm_Player.currentPlayingMusic.musicId isEqualToString:music.musicId];
        
        WeakSelf(self)
        [cell setClickAction:^(RCMusicLocalListCellActionType type) {
            StrongSelf(weakSelf)
            if (type == RCMusicLocalListCellActionTypeTop) {
                [strongSelf top:music];
            } else if (type == RCMusicLocalListCellActionTypeDelete) {
                [strongSelf _delete:music];
            } else if (type == RCMusicLocalListCellActionTypePlay){
                [strongSelf play:music];
            } else {
                [strongSelf stop:music];
            }
        }];
    } else {
        NSLog(@"local music list music_data out of bounds");
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"did selected");
}


#pragma mark -GETTER

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[RCMusicLocalListCell class] forCellReuseIdentifier:RCMusicLocalListCell.identifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorInset = self.appearance.separatorInset;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    return _tableView;
}

- (RCMusicLocalEmptyView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[RCMusicLocalEmptyView alloc] init];
        _emptyView.hidden = YES;
        WeakSelf(self)
        [_emptyView setAddMusicAction:^{
            StrongSelf(weakSelf)
            if ([strongSelf.delegate respondsToSelector:@selector(jumpToViewControllerWithPageType:)]) {
                [strongSelf.delegate jumpToViewControllerWithPageType:RCMusicPageTypeRemoteData];
            }
        }];
    }
    return _emptyView;
}

- (RCMusicListAppearance *)appearance {
    if (_appearance == nil) {
        _appearance = [[RCMusicListAppearance alloc] init];
    }
    return _appearance;
}
@end
