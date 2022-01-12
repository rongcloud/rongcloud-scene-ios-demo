//
//  RCMusicSearchBar.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicSearchBar : UIView
@property (nonatomic, weak) id<UISearchBarDelegate> delegate;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

NS_ASSUME_NONNULL_END
