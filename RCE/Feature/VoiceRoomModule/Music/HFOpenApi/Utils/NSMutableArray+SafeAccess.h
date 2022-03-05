//
//  NSMutableArray+SafeAccess.h
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableArray (SafeAccess)
- (id)hfv_objectAtIndex_Safe:(NSUInteger)index;

- (void)hfv_addObject_Safe:(id)object;
@end

NS_ASSUME_NONNULL_END
