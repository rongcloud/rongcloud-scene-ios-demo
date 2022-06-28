//
//  MHActionView.h
//  TXLiteAVDemo_UGC
//
//  Created by Apple on 2021/4/13.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class StickerDataListModel;
NS_ASSUME_NONNULL_BEGIN
@protocol MHActionViewDelegate <NSObject>
@required
- (void)handleStickerActionEffect:(NSString *)stickerContent sticker:(StickerDataListModel *)model action:(int)action;
@end
@interface MHActionView : UIView
@property (nonatomic, weak) id<MHActionViewDelegate> delegate;
- (void)getSticks;
- (void)clearAllActionEffects;
@end

NS_ASSUME_NONNULL_END
