//
//  RCMusicContainerViewController.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/18.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RCMusicPageType) {
    //本地收藏音乐列表
    RCMusicPageTypeLocalData = 0,
    //线上音乐列表
    RCMusicPageTypeRemoteData,
    //音乐控制页面
    RCMusicPageTypeControl,
};

@protocol RCMusicContainerViewControllerDelegate <NSObject>
@required
//tool bar item 点击跳转到置顶页面
- (void)jumpToViewControllerWithPageType:(RCMusicPageType)pageType;

@end

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicContainerViewController : UIViewController <RCMusicContainerViewControllerDelegate>

@end

NS_ASSUME_NONNULL_END
