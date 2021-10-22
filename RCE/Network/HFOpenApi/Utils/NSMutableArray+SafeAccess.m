//
//  NSMutableArray+SafeAccess.m
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/3.
//

#import "NSMutableArray+SafeAccess.h"

@implementation NSMutableArray (SafeAccess)
- (id)hfv_objectAtIndex_Safe:(NSUInteger)index {
    id object = nil;
    @try {
        if (index < self.count) {
            object = self[index];
            if (object == [NSNull null]) {
                object = nil;
            }
        }
    } @catch (NSException *exception) {
        
    } @finally {
        return object;
    }
}

- (void)hfv_addObject_Safe:(id)object{
    @try {
        [self addObject:object];
    } @catch (NSException *exception) {

    } @finally {
    }
}
@end
