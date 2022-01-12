//
//  RCMusicEffectInfoModel.h
//  RCE
//
//  Created by xuefeng on 2021/11/26.
//

#import <Foundation/Foundation.h>
#import "RCMusicEffectInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicEffectInfoModel : NSObject<RCMusicEffectInfo>
@property (nonatomic, copy) NSString *effectName;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) NSInteger soundId;
@end

NS_ASSUME_NONNULL_END
