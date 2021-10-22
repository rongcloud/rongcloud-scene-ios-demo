//
//  NSDictionary+SafeAccess.m
//  HFVMusic
//
//  Created by 灏 孙  on 2020/11/4.
//

#import "NSDictionary+SafeAccess.h"

@implementation NSDictionary (SafeAccess)
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
@end
