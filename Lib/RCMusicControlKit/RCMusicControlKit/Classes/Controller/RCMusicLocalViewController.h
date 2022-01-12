//
//  RCMusicLocalViewController.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import <UIKit/UIKit.h>
#import "RCMusicContainerViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface RCMusicLocalViewController : UIViewController
@property (nonatomic, weak) id<RCMusicContainerViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
