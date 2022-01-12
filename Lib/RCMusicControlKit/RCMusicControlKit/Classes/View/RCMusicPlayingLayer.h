//
//  RCMusicPlayingLayer.h
//  RCE
//
//  Created by xuefeng on 2021/11/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicPlayingLayer : CALayer
@property (nonatomic, assign) BOOL play;
- (void)startAnimation;
- (void)stopAnimation;
@end

NS_ASSUME_NONNULL_END
