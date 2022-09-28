//
//  RCRefreshStateHeader.h
//  RCE
//
//  Created by shaoshuai on 2021/9/8.
//

#import <MJRefresh/MJRefresh.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCRefreshStateHeader : MJRefreshStateHeader

@property (weak, nonatomic, readonly) UIImageView *arrowView;
@property (weak, nonatomic, readonly) UIActivityIndicatorView *loadingView;

@end

NS_ASSUME_NONNULL_END
