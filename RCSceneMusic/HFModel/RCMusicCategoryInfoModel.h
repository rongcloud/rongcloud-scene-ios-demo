//
//  RCMusicCategoryInfoModel.h
//  RCE
//
//  Created by xuefeng on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import "RCMusicCategoryInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicCategoryInfoModel : NSObject<RCMusicCategoryInfo>
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, assign) BOOL selected;
@end

NS_ASSUME_NONNULL_END
