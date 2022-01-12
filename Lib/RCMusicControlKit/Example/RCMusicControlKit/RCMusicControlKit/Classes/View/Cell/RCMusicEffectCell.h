//
//  RCMusicEffectCell.h
//  RCE
//
//  Created by xuefeng on 2021/11/26.
//

#import <UIKit/UIKit.h>
#import "RCMusicEffectInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMusicEffectCell : UICollectionViewCell
@property (class,nonatomic,copy) NSString *identifier;
@property (nonatomic, strong) id<RCMusicEffectInfo> item;
@end

NS_ASSUME_NONNULL_END
