//
//  RCMusicToolBarAppearance.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import "RCMusicAppearance.h"
#import "RCMusicAppearanceData.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicToolBarAppearance : RCMusicAppearance
//左边第一个item leading default 14
@property (nonatomic, assign) CGFloat leading;
//右边最后一个item trailing default -14
@property (nonatomic, assign) CGFloat trailing;
//item间隔 default 10
@property (nonatomic, assign) CGFloat spacing;
//item数据
@property (nonatomic, nullable, copy) NSArray<RCMusicBarItem *> *items;

//开启音乐控制功能
@property (nonatomic, assign) BOOL turnOnMusicControl;

//开启声音特效功能
@property (nonatomic, assign) BOOL turnOnSoundEffect;
@end

NS_ASSUME_NONNULL_END
