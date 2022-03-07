//
//  NSMutableDictionary+SafeAccess.h
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (SafeAccess)
- (id)hfv_objectForKey_Safe:(id)aKey;

- (void)hfv_setObject_Safe:(id)anObject forKey:(id)aKey;

- (void)hfv_removeObjectForKey_Safe:(id)aKey;
@end

NS_ASSUME_NONNULL_END
