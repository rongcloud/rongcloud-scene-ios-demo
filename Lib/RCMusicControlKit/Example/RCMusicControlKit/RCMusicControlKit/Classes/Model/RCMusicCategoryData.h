//
//  RCMusicCategoryData.h
//  RCMusicControlKit
//
//  Created by xuefeng on 2021/11/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCMusicCategoryData : NSObject
@property (nonatomic, copy, nonnull) NSString *titleText;
@property (nonatomic, copy, nonnull) NSString *categoryId;
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@end

NS_ASSUME_NONNULL_END
