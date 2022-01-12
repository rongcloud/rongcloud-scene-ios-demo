//
//  RCMusicControlViewController.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import "RCMusicControlViewController.h"
#import "RCMusicControlCell.h"
#import <Masonry/Masonry.h>
#import "RCMusicEngine.h"

#define rcm_Player [RCMusicEngine shareInstance].player

FOUNDATION_EXPORT NSString *const LocalVolumeKey;

FOUNDATION_EXPORT NSString *const RemoteVolumeKey;

FOUNDATION_EXPORT NSString *const MicVolumeKey;

FOUNDATION_EXPORT NSString *const EarReturnKey;

NSString *const LocalVolumeKey = @"本地音量";

NSString *const RemoteVolumeKey = @"远端音量";

NSString *const MicVolumeKey = @"麦克音量";

NSString *const EarReturnKey = @"开启耳返";

static NSArray *k_titleValues;

@interface RCMusicControlViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation RCMusicControlViewController

- (void)dealloc {
    NSLog(@"RCMusicControlViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSUInteger localVolume = rcm_Player.localVolume;
    NSUInteger remoteVolume = rcm_Player.remoteVolume;
    NSUInteger micVolume = rcm_Player.micVolume;
    
    k_titleValues = @[@{@"text":LocalVolumeKey,@"value":@(localVolume)},@{@"text":RemoteVolumeKey,@"value":@(remoteVolume)},@{@"text":MicVolumeKey,@"value":@(micVolume)},@{@"text":EarReturnKey,@"value":@(1)}];

    [self buildLayout];
    
}

- (void)buildLayout {
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[RCMusicControlCell class] forCellReuseIdentifier:RCMusicControlCell.identifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return k_titleValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RCMusicControlCell *cell = (RCMusicControlCell *)[tableView dequeueReusableCellWithIdentifier:RCMusicControlCell.identifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cellStyle = indexPath.row == 3 ? RCMusicControlCellStyleSwitch : RCMusicControlCellStyleSlider;
    cell.cellData = k_titleValues[indexPath.row];
    [cell setControlAction:^(RCMusicControlCellStyle cellStyle, NSString * _Nonnull text, NSInteger value) {
        if (text == LocalVolumeKey) {
            NSLog(@"LocalVolumeKey %ld",value);
            [rcm_Player setLocalVolume:value];
        } else if (text == RemoteVolumeKey) {
            NSLog(@"RemoteVolumeKey %ld",value);
            [rcm_Player setRemoteVolume:value];
        } else if (text == MicVolumeKey) {
            NSLog(@"MicVolumeKey %ld",value);
            [rcm_Player setMicVolume:value];
        } else {
            NSLog(@"EarReturnKey %ld",value);
            [rcm_Player setEarOpenMonitoring:value];
        }
    }];
    return cell;
}
@end
