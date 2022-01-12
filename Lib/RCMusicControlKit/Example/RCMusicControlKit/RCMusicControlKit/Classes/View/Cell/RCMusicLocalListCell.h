//
//  RCMusicLocalListCell.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/21.
//

#import <UIKit/UIKit.h>
#import "RCMusicInfo.h"

typedef NS_ENUM(NSUInteger, RCMusicLocalListCellActionType) {
    RCMusicLocalListCellActionTypeDelete = 1,
    RCMusicLocalListCellActionTypeTop,
    RCMusicLocalListCellActionTypePlay,
    RCMusicLocalListCellActionTypeStop,
};

NS_ASSUME_NONNULL_BEGIN
@interface RCMusicLocalListCell : UITableViewCell

@property (class, nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, strong) id<RCMusicInfo> music;

@property (nonatomic, copy) void(^clickAction)(RCMusicLocalListCellActionType type);

@property (nonatomic, assign) BOOL isPlaying;

@end

NS_ASSUME_NONNULL_END
