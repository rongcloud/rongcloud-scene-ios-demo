//
//  RCMusicSearchBar.m
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import "RCMusicSearchBar.h"
#import <Masonry/Masonry.h>
#import "UIImage+RCMBundle.h"
#import "RCMusicColors.h"
#import "UIImage+RCMBundle.h"

@interface RCMusicSearchBar ()<UISearchBarDelegate>
@end

@implementation RCMusicSearchBar

- (instancetype)init {
    if (self = [super init]) {
        [self buildLayout];
    }
    return self;
}

- (void)buildLayout {
    [self addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"搜索歌曲名称或者歌手";
        _searchBar.delegate = self;
        _searchBar.tintColor = mainColor;
        _searchBar.showsBookmarkButton = YES;
        [_searchBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
        [_searchBar setSearchFieldBackgroundImage:[self searchBarFieldBackgroundImage] forState:UIControlStateNormal];
        [_searchBar setImage:[UIImage rcm_imageNamed:@"music_close"] forSearchBarIcon:UISearchBarIconBookmark state:UIControlStateNormal];
        [_searchBar setPositionAdjustment:UIOffsetMake(-4, 0) forSearchBarIcon:UISearchBarIconBookmark];
        if (@available(iOS 13.0, *)) {
            _searchBar.searchTextField.borderStyle = UITextBorderStyleNone;
            _searchBar.searchTextField.layer.masksToBounds = YES;
            _searchBar.searchTextField.layer.cornerRadius = 10;
        } else {
            for (UIView *view in _searchBar.subviews) {
                if ([view isKindOfClass:NSClassFromString(@"_UISearchBarSearchFieldBackgroundView")]) {
                    view.layer.cornerRadius = 10.0f;
                    view.layer.masksToBounds = YES;
                    break;
                }
            }
        }
    }
    return _searchBar;
}

- (UIImage *)searchBarFieldBackgroundImage {
    CGRect rect = CGRectMake(0, 0, 1, 40);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector: @selector(searchBarShouldBeginEditing:)]) {
        return [self.delegate searchBarShouldBeginEditing:searchBar];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    NSLog(@"search result %@",searchBar.text);
    if ([self.delegate respondsToSelector: @selector(searchBarTextDidEndEditing:)]) {
        [self.delegate searchBarTextDidEndEditing:searchBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"search result %@",searchText);
    if ([self.delegate respondsToSelector: @selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:searchBar textDidChange:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if ([self.delegate respondsToSelector: @selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:searchBar];
    }
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    if ([self.delegate respondsToSelector: @selector(searchBarBookmarkButtonClicked:)]) {
        [self.delegate searchBarBookmarkButtonClicked:searchBar];
    }
}
@end
