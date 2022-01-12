//
//  NSDictionary+SafeAccess.h
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (SafeAccess)
- (id)hfv_objectForKey_Safe:(id)aKey;

@end

NS_ASSUME_NONNULL_END
