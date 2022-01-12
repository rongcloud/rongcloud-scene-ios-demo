//
//  RCMusicCategoryInfo.h
//  RCE
//
//  Created by xuefeng on 2021/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RCMusicCategoryInfo <NSObject>
@required
//类别id
@property (nullable, nonatomic, copy) NSString *categoryId;
//类别名称
@property (nullable, nonatomic, copy) NSString *categoryName;
//计算属性是否被选中
@property (nonatomic, assign) BOOL selected;
@end

NS_ASSUME_NONNULL_END
