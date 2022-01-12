//
//  RCMusicToolBar.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/15.
//

#import <UIKit/UIKit.h>
#import "RCMusicToolBarItem.h"
@class RCMusicToolBarAppearance;

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicToolBar : UIView
@property (nonatomic, copy) NSArray <__kindof RCMusicToolBarItem*> *leftItems;
@property (nonatomic, copy) NSArray <__kindof RCMusicToolBarItem*> *rightItems;


- (instancetype)initWithItems:(NSArray <__kindof RCMusicToolBarItem*> * _Nullable)items;

- (instancetype)initWithLeftItems:(NSArray <__kindof RCMusicToolBarItem*> * _Nullable)leftItems rightItems:(NSArray <__kindof RCMusicToolBarItem*> * _Nullable)rightItems;

@end

NS_ASSUME_NONNULL_END
