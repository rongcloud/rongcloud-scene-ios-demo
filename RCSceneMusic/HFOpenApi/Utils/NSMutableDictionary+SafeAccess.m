//
//  NSMutableDictionary+SafeAccess.m
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/3.
//

#import "NSMutableDictionary+SafeAccess.h"

@implementation NSMutableDictionary (SafeAccess)
- (id)hfv_objectForKey_Safe:(id)aKey
{
    id object = nil;
    @try {
        object = [self objectForKey:aKey];
        if (object == [NSNull null]) {
            object = nil;
        }
    } @catch (NSException *exception) {

    } @finally {
        return object;
    }
}

- (void)hfv_setObject_Safe:(id)anObject forKey:(id)aKey{

    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }

}

- (void)hfv_removeObjectForKey_Safe:(id)aKey {
    @try {
        [self removeObjectForKey:aKey];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}
@end
