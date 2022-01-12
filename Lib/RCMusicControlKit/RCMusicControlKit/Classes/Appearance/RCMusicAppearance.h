//
//  RCMusicAppearance.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicAppearance : NSObject
//背景颜色
@property (nonatomic, strong) UIColor *backgroundColor;

/// 初始化配置文件
/// @param dict 配置文件内容字典
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
