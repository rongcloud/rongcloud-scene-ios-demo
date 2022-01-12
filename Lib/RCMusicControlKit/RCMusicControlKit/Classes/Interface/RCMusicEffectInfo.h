//
//  RCMusicEffectInfo.h
//  RCE
//
//  Created by xuefeng on 2021/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCMusicEffectInfo <NSObject>
//特效名称
@property (nullable, nonatomic, copy) NSString *effectName;
//特效资源地址
@property (nullable, nonatomic, copy) NSString *filePath;
//特效资源id
@property (nonatomic, assign) NSInteger soundId;
@end

NS_ASSUME_NONNULL_END
