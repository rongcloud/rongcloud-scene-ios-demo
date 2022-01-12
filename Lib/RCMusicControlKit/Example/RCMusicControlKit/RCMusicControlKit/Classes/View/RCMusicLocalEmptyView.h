//
//  RCMusicLocalEmptyView.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicLocalEmptyView : UIView
@property (nonatomic, copy) void(^addMusicAction)(void);
@end

NS_ASSUME_NONNULL_END
