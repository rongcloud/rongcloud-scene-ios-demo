//
//  RCMusicSoundEffectToolView.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/22.
//

#import <UIKit/UIKit.h>
#import "RCMusicEffectInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicSoundEffectToolView : UIView
@property (nonatomic, copy) NSArray<RCMusicEffectInfo> *items;
@property (nonatomic, copy) void(^itemClick)(id<RCMusicEffectInfo> info);
@end

NS_ASSUME_NONNULL_END
