//
//  RCMusicInfoBubbleView.h
//  RCE
//
//  Created by xuefeng on 2021/11/28.
//

#import <UIKit/UIKit.h>
#import "RCMusicInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicInfoBubbleView : UIView
@property (nonatomic, strong, nullable) id<RCMusicInfo> info;
@end

NS_ASSUME_NONNULL_END
