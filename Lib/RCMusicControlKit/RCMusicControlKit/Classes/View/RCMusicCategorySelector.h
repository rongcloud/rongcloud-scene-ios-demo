//
//  RCMusicCategorySelector.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import <UIKit/UIKit.h>
#import "RCMusicCategoryInfo.h"

@protocol RCMusicCategorySelectorDelegate <NSObject>
@required
- (void)categoryDidSelectItemAtIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicCategorySelector : UIView
@property (nonatomic, copy) NSArray<RCMusicCategoryInfo> *items;
@property (nonatomic, weak) id<RCMusicCategorySelectorDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
