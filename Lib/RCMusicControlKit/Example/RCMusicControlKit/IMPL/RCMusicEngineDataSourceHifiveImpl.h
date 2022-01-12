//
//  RCMusicEngineDataSourceMediator.h
//  RCE
//
//  Created by xuefeng on 2021/11/24.
//

#import <Foundation/Foundation.h>
#import "RCMusicEngineDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicEngineDataSourceHifiveImpl : NSObject<RCMusicEngineDataSource>
+ (instancetype)instance;
@end

NS_ASSUME_NONNULL_END
